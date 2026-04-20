/// App-wide string/duration constants shared across features.
class AppConstants {
  AppConstants._();

  static const String appName = 'UGO Admin';

  // Cache
  static const String dashboardCacheKey = 'dashboard_v1';
  static const Duration dashboardCacheTtl = Duration(minutes: 15);

  // Pagination
  static const int defaultPageSize = 20;
}
