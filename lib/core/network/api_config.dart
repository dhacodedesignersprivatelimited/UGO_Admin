/// API Configuration - matches Postman collection variables
/// Change baseUrl for: localhost:5001 (local) | ugocabs production
class ApiConfig {
  ApiConfig._();

  // static const String baseUrl = 'https://ugotaxi.icacorp.org';
  static const String baseUrl = 'https://ugo-api.icacorp.org';
  // For local: 'http://localhost:5001' or 'http://10.0.2.2:5001' (Android emulator)
  static String get apiBase => '$baseUrl/api';
}
