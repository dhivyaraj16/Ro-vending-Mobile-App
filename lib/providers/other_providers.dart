// machine_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MachineProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ROmachine> _machines = [];
  ROmachine? _selectedMachine;
  bool _isLoading = false;

  List<ROmachine> get machines => _machines;
  ROmachine? get selectedMachine => _selectedMachine;
  bool get isLoading => _isLoading;

  // ── Fetch all machines via API (mock or real) ──
  Future<void> fetchMachines() async {
    try {
      _isLoading = true;
      notifyListeners();

      _machines = await ApiService.instance.getMachines();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching machines from API, trying Firestore: $e');
      // Fallback to Firestore if API fails
      try {
        final snapshot = await _firestore.collection('machines').get();
        _machines = snapshot.docs
            .map((doc) => ROmachine.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
        notifyListeners();
      } catch (e2) {
        debugPrint('Firestore fallback also failed: $e2');
      }
    }
  }

  // ── Firestore real-time stream (still available if needed) ──
  Stream<List<ROmachine>> getMachinesStream() {
    return _firestore.collection('machines').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ROmachine.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // ── Get machine by QR code via API ──
  Future<ROmachine?> getMachineByCode(String code) async {
    try {
      final machine = await ApiService.instance.getMachineByCode(code);
      if (machine != null) {
        _selectedMachine = machine;
        notifyListeners();
      }
      return machine;
    } catch (e) {
      debugPrint('API getMachineByCode failed, trying Firestore: $e');
      // Fallback to Firestore
      try {
        final snapshot = await _firestore
            .collection('machines')
            .where('machineCode', isEqualTo: code)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final machine = ROmachine.fromMap(
              {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
          _selectedMachine = machine;
          notifyListeners();
          return machine;
        }
      } catch (_) {}
    }
    return null;
  }

  void selectMachine(ROmachine machine) {
    _selectedMachine = machine;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMachine = null;
    notifyListeners();
  }
}

// transaction_provider.dart

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore2 = FirebaseFirestore.instance;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _firestore2
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> fetchTransactions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore2
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  double getTotalSpent() {
    return _transactions
        .where((t) => t.type == TransactionType.waterPurchase)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalLitres() {
    return _transactions
        .where((t) => t.type == TransactionType.waterPurchase)
        .fold(0.0, (sum, t) => sum + (t.litresDispensed ?? 0));
  }
}

// chat_provider.dart

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore3 = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<ChatMessage>> getMessagesStream(String userId) {
    return _firestore3
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> sendMessage({
    required String userId,
    required String message,
    required String senderName,
  }) async {
    try {
      final msgRef = _firestore3
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .doc();

      final chatMsg = ChatMessage(
        id: msgRef.id,
        senderId: userId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
        isSupport: false,
      );

      await msgRef.set(chatMsg.toMap());

      // Update chat metadata
      await _firestore3.collection('chats').doc(userId).set({
        'userId': userId,
        'userName': senderName,
        'lastMessage': message,
        'lastMessageTime': DateTime.now(),
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }
}
