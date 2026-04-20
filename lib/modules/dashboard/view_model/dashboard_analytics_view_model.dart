import 'package:flutter/foundation.dart';

import '/shared/admin_staff_role.dart';
import '/shared/loadable.dart';
import '/modules/dashboard/model/dashboard_model.dart';
import '/modules/dashboard/repository/analytics_admin_repository.dart';

class DashboardAnalyticsViewModel extends ChangeNotifier {
  DashboardAnalyticsViewModel({
    required AnalyticsAdminRepository repository,
    required AdminPrincipal principal,
  })  : _repository = repository,
        _principal = principal;

  final AnalyticsAdminRepository _repository;
  final AdminPrincipal _principal;

  Loadable<DashboardAnalytics> analyticsState = const Loadable();

  bool get canView => _principal.can(AdminPermission.viewDashboard);

  Future<void> refresh() async {
    if (!canView) {
      analyticsState = const Loadable(
        status: LoadStatus.failure,
        message: 'Insufficient permissions',
      );
      notifyListeners();
      return;
    }
    analyticsState = analyticsState.copyWith(status: LoadStatus.loading);
    notifyListeners();
    try {
      final data = await _repository.dashboard();
      analyticsState = Loadable(status: LoadStatus.success, data: data);
    } catch (e) {
      analyticsState = Loadable(status: LoadStatus.failure, message: e.toString());
    }
    notifyListeners();
  }
}
