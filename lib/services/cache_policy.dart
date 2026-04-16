class CachePolicy {
  CachePolicy._();

  static const String dashboardKey = 'dashboard_overview';
  static const String vehiclesKey = 'vehicles_list';
  static const String walletKey = 'wallet_management';

  static const Duration dashboardTtl = Duration(minutes: 2);
  static const Duration vehiclesTtl = Duration(minutes: 3);
  static const Duration walletTtl = Duration(minutes: 2);
}
