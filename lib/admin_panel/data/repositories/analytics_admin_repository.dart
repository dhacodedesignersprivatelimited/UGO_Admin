import '../api/admin_api_contract.dart';
import '../models/analytics_models.dart';

class AnalyticsAdminRepository {
  AnalyticsAdminRepository(this._api);

  final AdminApiContract _api;

  Future<DashboardAnalytics> dashboard() => _api.fetchDashboardAnalytics();
}
