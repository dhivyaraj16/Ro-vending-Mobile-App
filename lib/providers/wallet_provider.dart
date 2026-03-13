import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';

class WalletProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;

  double _balance = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  WalletProvider() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void initWallet(double balance) {
    _balance = balance;
    notifyListeners();
  }

  Future<void> fetchBalance(String userId) async {
    try {
      _balance = await ApiService.instance.getWalletBalance(userId);
      notifyListeners();
    } catch (e) {
      // Fallback to Firestore
      try {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          _balance = (doc.data()?['walletBalance'] ?? 0.0).toDouble();
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  void openRazorpay({
    required double amount,
    required String userId,
    required String userEmail,
    required String userPhone,
    required String userName,
  }) {
    final options = {
      'key': 'YOUR_RAZORPAY_KEY_ID',
      'amount': (amount * 100).toInt(),
      'name': 'RO Vending Machine',
      'description': 'Wallet Recharge',
      'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
      'theme': {'color': '#7c3aed'},
      'external': {'wallets': ['paytm', 'phonepe', 'googlepay']},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      _errorMessage = 'Payment gateway error: $e';
      notifyListeners();
    }
  }

  String? _pendingUserId;
  double? _pendingAmount;

  void setPendingTransaction(String userId, double amount) {
    _pendingUserId = userId;
    _pendingAmount = amount;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingUserId == null || _pendingAmount == null) return;
    try {
      final result = await ApiService.instance.rechargeWallet(
        userId: _pendingUserId!,
        amount: _pendingAmount!,
        paymentId: response.paymentId ?? '',
      );
      if (result.isSuccess) {
        await _firestore.collection('users').doc(_pendingUserId).update({
          'walletBalance': FieldValue.increment(_pendingAmount!),
        });
        _balance += _pendingAmount!;
        _successMessage = 'Rs.${_pendingAmount!.toStringAsFixed(0)} added successfully!';
      } else {
        _errorMessage = 'Wallet update failed. Contact support.';
      }
      _pendingUserId = null;
      _pendingAmount = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update wallet: $e';
      notifyListeners();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _errorMessage = 'Payment failed: ${response.message}';
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
  }

  Future<bool> deductForWater({
    required String userId,
    required String machineId,
    required String machineName,
    required double amount,
    required double litres,
  }) async {
    if (_balance < amount) {
      _errorMessage = 'Insufficient wallet balance!';
      notifyListeners();
      return false;
    }
    try {
      _isLoading = true;
      notifyListeners();

      // Call API to dispense
      final result = await ApiService.instance.requestDispense(
        machineId: machineId,
        litres: litres,
        userId: userId,
        paymentMethod: 'wallet',
      );

      if (!result.isApproved) {
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sync to Firestore for admin dashboard
      final txId = const Uuid().v4();
      final batch = _firestore.batch();
      batch.update(_firestore.collection('users').doc(userId),
          {'walletBalance': FieldValue.increment(-amount)});
      batch.set(
        _firestore.collection('transactions').doc(txId),
        TransactionModel(
          id: txId, userId: userId, machineId: machineId,
          machineName: machineName, type: TransactionType.waterPurchase,
          status: TransactionStatus.success, amount: amount,
          litresDispensed: litres, createdAt: DateTime.now(),
          description: '${litres}L water from $machineName',
        ).toMap(),
      );
      batch.update(_firestore.collection('machines').doc(machineId),
          {'totalWaterDispensed': FieldValue.increment(litres)});
      await batch.commit();

      _balance -= amount;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Transaction failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
