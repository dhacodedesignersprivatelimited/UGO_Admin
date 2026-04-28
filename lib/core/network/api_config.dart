/// API Configuration used across admin API calls.
class ApiConfig {
  ApiConfig._();

  /// Canonical backend host for this project.
  static const String baseUrl = 'https://ugo-api.icacorp.org';

  static String get apiBase => '$baseUrl/api';
}
