import 'package:flutter/foundation.dart';

import '/shared/admin_staff_role.dart';
import '/shared/loadable.dart';
import '/shared/models/domain_enums.dart';
import '/modules/user_management/model/users_model.dart';
import '/modules/user_management/repository/user_admin_repository.dart';

class UserModuleViewModel extends ChangeNotifier {
  UserModuleViewModel({
    required UserAdminRepository repository,
    required AdminPrincipal principal,
  })  : _repository = repository,
        _principal = principal;

  final UserAdminRepository _repository;
  final AdminPrincipal _principal;

  Loadable<List<RiderListItem>> ridersState = const Loadable();
  Loadable<List<RiderComplaint>> complaintsState = const Loadable();
  String riderQuery = '';

  bool get canManageWallets => _principal.can(AdminPermission.manageRiderWallets);
  bool get canManageComplaints => _principal.can(AdminPermission.manageComplaints);

  Future<void> refreshRiders() async {
    ridersState = ridersState.copyWith(status: LoadStatus.loading);
    notifyListeners();
    try {
      final data = await _repository.listRiders(
        query: riderQuery.isEmpty ? null : riderQuery,
      );
      ridersState = Loadable(status: LoadStatus.success, data: data);
    } catch (e) {
      ridersState = Loadable(status: LoadStatus.failure, message: e.toString());
    }
    notifyListeners();
  }

  Future<void> refreshComplaints() async {
    complaintsState = complaintsState.copyWith(status: LoadStatus.loading);
    notifyListeners();
    try {
      final data = await _repository.complaints();
      complaintsState = Loadable(status: LoadStatus.success, data: data);
    } catch (e) {
      complaintsState = Loadable(status: LoadStatus.failure, message: e.toString());
    }
    notifyListeners();
  }

  Future<void> searchRiders(String value) async {
    riderQuery = value;
    await refreshRiders();
  }

  Future<void> toggleBlock(String riderId, bool blocked) async {
    if (!_principal.can(AdminPermission.manageRiders)) return;
    await _repository.setBlocked(riderId, blocked);
    await refreshRiders();
  }

  Future<void> resolveComplaint(String id) async {
    if (!canManageComplaints) return;
    await _repository.updateComplaint(id, ComplaintStatus.resolved);
    await refreshComplaints();
  }
}
