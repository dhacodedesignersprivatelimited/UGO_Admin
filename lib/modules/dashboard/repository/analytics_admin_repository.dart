import '/core/network/admin_api_contract.dart';
import '/modules/dashboard/model/dashboard_model.dart';

class AnalyticsAdminRepository {
  AnalyticsAdminRepository(this._api);

  final AdminApiContract _api;

  Future<DashboardAnalytics> dashboard() => _api.fetchDashboardAnalytics();
}
