import '/core/auth/auth_util.dart';
import '/core/network/admin_api_contract.dart';
import '/core/network/http_admin_api_client.dart';
import '/core/network/mock_admin_api_client.dart';
import '/modules/dashboard/repository/analytics_admin_repository.dart';
import '/modules/driver_management/repository/driver_admin_repository.dart';
import '/modules/finance_management/repository/finance_admin_repository.dart';
import '/modules/ride_management/repository/rides_admin_repository.dart';
import '/modules/settings/repository/settings_admin_repository.dart';
import '/modules/user_management/repository/user_admin_repository.dart';

/// Composition root for the modular admin layer. Inject a real API for production.
class AdminPanelDependencies {
  AdminPanelDependencies({
    required AdminApiContract api,
  }) : _api = api;

  factory AdminPanelDependencies.mock() =>
      AdminPanelDependencies(api: MockAdminApiClient());

  /// Uses existing `*Call` / [ApiManager] stack with the current admin JWT.
  factory AdminPanelDependencies.http({
    String? Function()? tokenResolver,
  }) {
    return AdminPanelDependencies(
      api: HttpAdminApiClient(
        tokenResolver: tokenResolver ?? () => currentAuthenticationToken,
      ),
    );
  }

  final AdminApiContract _api;

  late final DriverAdminRepository drivers = DriverAdminRepository(_api);
  late final UserAdminRepository users = UserAdminRepository(_api);
  late final RidesAdminRepository rides = RidesAdminRepository(_api);
  late final FinanceAdminRepository finance = FinanceAdminRepository(_api);
  late final SettingsAdminRepository settings = SettingsAdminRepository(_api);
  late final AnalyticsAdminRepository analytics = AnalyticsAdminRepository(_api);
}
