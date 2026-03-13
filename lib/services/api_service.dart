// ============================================================
// lib/services/api_service.dart
//
// இந்த file-ல் எதுவும் மாத்த வேண்டாம்.
// api_config.dart-ல் useMockData = false, baseUrl மாத்தினா
// automatically real API use ஆகும்.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';
import 'mock_data.dart';

class ApiService {
  // Singleton
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _authToken;

  void setToken(String token) => _authToken = token;
  void clearToken() => _authToken = null;

  // ── Internal HTTP helpers ──
  Future<Map<String, dynamic>> _get(String endpoint) async {
    final res = await http
        .get(
          Uri.parse(endpoint),
          headers: ApiConfig.headers(_authToken ?? ''),
        )
        .timeout(ApiConfig.timeout);

    if (res.statusCode == 200) return jsonDecode(res.body);
    throw ApiException(res.statusCode, res.body);
  }

  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    final res = await http
        .post(
          Uri.parse(endpoint),
          headers: ApiConfig.headers(_authToken ?? ''),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException(res.statusCode, res.body);
  }

  // ══════════════════════════════════════════
  // MACHINES
  // ══════════════════════════════════════════

  /// Get all machines
  Future<List<ROmachine>> getMachines() async {
    if (ApiConfig.useMockData) {
      // Mock: simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.machines.map((m) => _machineFromApi(m)).toList();
    }

    // Real API
    final data = await _get(ApiConfig.machinesEndpoint);
    final list = data['machines'] as List? ?? data as List;
    return (list as List).map((m) => _machineFromApi(m)).toList();
  }

  /// Get single machine by QR code
  Future<ROmachine?> getMachineByCode(String code) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final found = MockData.machines
          .firstWhere((m) => m['machineCode'] == code, orElse: () => {});
      if (found.isEmpty) return null;
      return _machineFromApi(found);
    }

    final data = await _get('${ApiConfig.machinesEndpoint}/code/$code');
    return _machineFromApi(data['machine'] ?? data);
  }

  // ══════════════════════════════════════════
  // TRANSACTIONS
  // ══════════════════════════════════════════

  /// Get user's transaction history
  Future<List<TransactionModel>> getTransactions(String userId) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.transactionsForUser(userId)
          .map((t) => _transactionFromApi(t))
          .toList();
    }

    final data = await _get(
        '${ApiConfig.transactionsEndpoint}?userId=$userId&limit=50');
    final list = data['transactions'] as List? ?? data as List;
    return (list as List).map((t) => _transactionFromApi(t)).toList();
  }

  // ══════════════════════════════════════════
  // DISPENSER
  // ══════════════════════════════════════════

  /// Request water dispensing
  Future<DispenseResult> requestDispense({
    required String machineId,
    required double litres,
    required String userId,
    required String paymentMethod, // 'wallet' | 'upi' | 'card'
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      final data = MockData.dispenseResponse(machineId, litres);
      return DispenseResult.fromMap(data);
    }

    final data = await _post(ApiConfig.dispenserEndpoint, {
      'machineId': machineId,
      'litres': litres,
      'userId': userId,
      'paymentMethod': paymentMethod,
    });
    return DispenseResult.fromMap(data);
  }

  // ══════════════════════════════════════════
  // WALLET
  // ══════════════════════════════════════════

  /// Recharge wallet
  Future<WalletTopupResult> rechargeWallet({
    required String userId,
    required double amount,
    required String paymentId,
  }) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      final data = MockData.walletTopupResponse(amount);
      return WalletTopupResult.fromMap(data);
    }

    final data = await _post('${ApiConfig.walletEndpoint}/recharge', {
      'userId': userId,
      'amount': amount,
      'paymentId': paymentId,
    });
    return WalletTopupResult.fromMap(data);
  }

  /// Get wallet balance
  Future<double> getWalletBalance(String userId) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return 150.0; // mock balance
    }

    final data = await _get('${ApiConfig.walletEndpoint}/$userId/balance');
    return (data['balance'] ?? 0.0).toDouble();
  }

  // ══════════════════════════════════════════
  // HELPERS - Map API response → Model
  // ══════════════════════════════════════════

  ROmachine _machineFromApi(Map<String, dynamic> m) {
    return ROmachine(
      id:                   m['id']?.toString()              ?? '',
      name:                 m['name']?.toString()            ?? '',
      address:              m['address']?.toString()         ?? '',
      latitude:             (m['latitude']  ?? 0.0).toDouble(),
      longitude:            (m['longitude'] ?? 0.0).toDouble(),
      isOnline:             m['isOnline']   ?? m['is_online'] ?? false,
      isAvailable:          m['isAvailable'] ?? m['is_available'] ?? false,
      pricePerLitre:        (m['pricePerLitre'] ?? m['price_per_litre'] ?? 3.0).toDouble(),
      totalWaterDispensed:  (m['totalWaterDispensed'] ?? 0.0).toDouble(),
      totalUsers:           (m['totalUsers'] ?? 0) as int,
      machineCode:          m['machineCode'] ?? m['machine_code'] ?? '',
      lastMaintenance:      m['lastMaintenance'] is DateTime
                              ? m['lastMaintenance']
                              : DateTime.tryParse(m['lastMaintenance']?.toString() ?? '') ?? DateTime.now(),
      imageUrl:             m['imageUrl'] ?? m['image_url'],
    );
  }

  TransactionModel _transactionFromApi(Map<String, dynamic> t) {
    return TransactionModel(
      id:               t['id']?.toString()       ?? '',
      userId:           t['userId']?.toString()   ?? '',
      machineId:        t['machineId']?.toString(),
      machineName:      t['machineName']?.toString(),
      type:             TransactionType.values.firstWhere(
                          (e) => e.name == (t['type'] ?? 'waterPurchase'),
                          orElse: () => TransactionType.waterPurchase),
      status:           TransactionStatus.values.firstWhere(
                          (e) => e.name == (t['status'] ?? 'success'),
                          orElse: () => TransactionStatus.success),
      amount:           (t['amount'] ?? 0.0).toDouble(),
      litresDispensed:  t['litresDispensed']?.toDouble(),
      createdAt:        t['createdAt'] is DateTime
                          ? t['createdAt']
                          : DateTime.tryParse(t['createdAt']?.toString() ?? '') ?? DateTime.now(),
      paymentId:        t['paymentId']?.toString(),
      description:      t['description']?.toString() ?? '',
    );
  }
}

// ══════════════════════════════════════════
// RESULT MODELS
// ══════════════════════════════════════════

class DispenseResult {
  final String sessionId;
  final String machineId;
  final double litresRequested;
  final double amount;
  final String status; // 'approved' | 'rejected'
  final String message;

  DispenseResult({
    required this.sessionId,
    required this.machineId,
    required this.litresRequested,
    required this.amount,
    required this.status,
    required this.message,
  });

  bool get isApproved => status == 'approved';

  factory DispenseResult.fromMap(Map<String, dynamic> m) => DispenseResult(
    sessionId:        m['sessionId']?.toString()  ?? '',
    machineId:        m['machineId']?.toString()  ?? '',
    litresRequested:  (m['litresRequested'] ?? 0.0).toDouble(),
    amount:           (m['amount'] ?? 0.0).toDouble(),
    status:           m['status']?.toString()     ?? 'rejected',
    message:          m['message']?.toString()    ?? '',
  );
}

class WalletTopupResult {
  final String transactionId;
  final double amount;
  final double newBalance;
  final String status;
  final String message;

  WalletTopupResult({
    required this.transactionId,
    required this.amount,
    required this.newBalance,
    required this.status,
    required this.message,
  });

  bool get isSuccess => status == 'success';

  factory WalletTopupResult.fromMap(Map<String, dynamic> m) => WalletTopupResult(
    transactionId: m['transactionId']?.toString() ?? '',
    amount:        (m['amount']     ?? 0.0).toDouble(),
    newBalance:    (m['newBalance'] ?? 0.0).toDouble(),
    status:        m['status']?.toString()  ?? 'failed',
    message:       m['message']?.toString() ?? '',
  );
}

// ══════════════════════════════════════════
// EXCEPTION
// ══════════════════════════════════════════

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
