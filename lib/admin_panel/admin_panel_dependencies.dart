import '/auth/custom_auth/auth_util.dart';

import 'data/api/admin_api_contract.dart';
import 'data/api/http_admin_api_client.dart';
import 'data/api/mock_admin_api_client.dart';
import 'data/repositories/analytics_admin_repository.dart';
import 'data/repositories/driver_admin_repository.dart';
import 'data/repositories/finance_admin_repository.dart';
import 'data/repositories/rides_admin_repository.dart';
import 'data/repositories/settings_admin_repository.dart';
import 'data/repositories/user_admin_repository.dart';

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
