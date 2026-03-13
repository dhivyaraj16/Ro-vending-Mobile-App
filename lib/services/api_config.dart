// ============================================================
// lib/services/api_config.dart
//
// 🔧 FUTURE SWITCH: இந்த ஒரே file மட்டும் மாத்தினா போதும்!
//
//   இப்போ (Mock):   useMockData = true
//   Real API ready: useMockData = false
//                   baseUrl     = "https://company-api.com"
// ============================================================

class ApiConfig {
  // ──────────────────────────────────────────
  // 👇 ONLY THESE 2 LINES NEED TO CHANGE
  // ──────────────────────────────────────────
  static const bool useMockData = true;
  static const String baseUrl   = 'https://api.rovending.company.com';
  // ──────────────────────────────────────────

  // API version prefix
  static const String apiVersion = '/api/v1';

  // Full base
  static String get base => '$baseUrl$apiVersion';

  // Endpoints
  static String get machinesEndpoint     => '$base/machines';
  static String get transactionsEndpoint => '$base/transactions';
  static String get usersEndpoint        => '$base/users';
  static String get dispenserEndpoint    => '$base/dispenser';
  static String get walletEndpoint       => '$base/wallet';

  // Request timeout
  static const Duration timeout = Duration(seconds: 15);

  // Auth header helper
  static Map<String, String> headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
