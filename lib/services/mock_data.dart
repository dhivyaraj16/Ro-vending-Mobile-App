// ============================================================
// lib/services/mock_data.dart
//
// இப்போ use ஆகுது. Real API ready ஆனா இந்த file தேவையில்லை.
// ============================================================

import '../models/models.dart';

class MockData {
  // ── Machines ──
  static List<Map<String, dynamic>> get machines => [
    {
      'id': 'RO-001',
      'name': 'RO Vending MG Road',
      'address': 'MG Road, Sector 14, Coimbatore',
      'latitude': 11.0168,
      'longitude': 76.9558,
      'isOnline': true,
      'isAvailable': true,
      'pricePerLitre': 3.0,
      'totalWaterDispensed': 12450.0,
      'totalUsers': 342,
      'machineCode': 'RO001',
      'waterLevel': 85,
      'tdsLevel': 28,
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 'RO-002',
      'name': 'RO Vending Gandhi Nagar',
      'address': 'Gandhi Nagar, Block A, Coimbatore',
      'latitude': 11.0250,
      'longitude': 76.9690,
      'isOnline': true,
      'isAvailable': true,
      'pricePerLitre': 3.0,
      'totalWaterDispensed': 9870.0,
      'totalUsers': 218,
      'machineCode': 'RO002',
      'waterLevel': 92,
      'tdsLevel': 32,
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 'RO-003',
      'name': 'RO Vending Central Market',
      'address': 'Central Market, Coimbatore',
      'latitude': 11.0010,
      'longitude': 76.9620,
      'isOnline': false,
      'isAvailable': false,
      'pricePerLitre': 3.0,
      'totalWaterDispensed': 7230.0,
      'totalUsers': 156,
      'machineCode': 'RO003',
      'waterLevel': 45,
      'tdsLevel': 48,
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 12)),
    },
    {
      'id': 'RO-004',
      'name': 'RO Vending East Street',
      'address': 'East Street, Zone 3, Coimbatore',
      'latitude': 11.0320,
      'longitude': 76.9780,
      'isOnline': true,
      'isAvailable': true,
      'pricePerLitre': 3.0,
      'totalWaterDispensed': 15600.0,
      'totalUsers': 391,
      'machineCode': 'RO004',
      'waterLevel': 78,
      'tdsLevel': 25,
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  // ── Transactions ──
  static List<Map<String, dynamic>> transactionsForUser(String userId) => [
    {
      'id': 'TXN-${userId.substring(0, 4)}-001',
      'userId': userId,
      'machineId': 'RO-001',
      'machineName': 'RO Vending MG Road',
      'type': 'waterPurchase',
      'status': 'success',
      'amount': 15.0,
      'litresDispensed': 5.0,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      'description': '5L water purchase',
    },
    {
      'id': 'TXN-${userId.substring(0, 4)}-002',
      'userId': userId,
      'machineId': null,
      'machineName': null,
      'type': 'walletTopup',
      'status': 'success',
      'amount': 100.0,
      'litresDispensed': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'Wallet recharge',
    },
    {
      'id': 'TXN-${userId.substring(0, 4)}-003',
      'userId': userId,
      'machineId': 'RO-004',
      'machineName': 'RO Vending East Street',
      'type': 'waterPurchase',
      'status': 'success',
      'amount': 30.0,
      'litresDispensed': 10.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      'description': '10L water purchase',
    },
  ];

  // ── Dispense response ──
  static Map<String, dynamic> dispenseResponse(String machineId, double litres) => {
    'sessionId': 'SESS-${DateTime.now().millisecondsSinceEpoch}',
    'machineId': machineId,
    'litresRequested': litres,
    'amount': litres * 3.0,
    'status': 'approved',
    'message': 'Dispensing started. Please collect your water.',
  };

  // ── Wallet topup ──
  static Map<String, dynamic> walletTopupResponse(double amount) => {
    'transactionId': 'PAY-${DateTime.now().millisecondsSinceEpoch}',
    'amount': amount,
    'newBalance': amount, // provider will add to existing
    'status': 'success',
    'message': 'Wallet recharged successfully',
  };
}
