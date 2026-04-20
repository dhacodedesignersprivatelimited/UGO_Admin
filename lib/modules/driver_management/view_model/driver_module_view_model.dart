import 'package:flutter/foundation.dart';

import '/shared/admin_staff_role.dart';
import '/shared/loadable.dart';
import '/shared/models/domain_enums.dart';
import '/modules/driver_management/model/drivers_model.dart';
import '/modules/driver_management/repository/driver_admin_repository.dart';

class DriverModuleViewModel extends ChangeNotifier {
  DriverModuleViewModel({
    required DriverAdminRepository repository,
    required AdminPrincipal principal,
  })  : _repository = repository,
        _principal = principal;

  final DriverAdminRepository _repository;
  final AdminPrincipal _principal;

  Loadable<List<DriverListItem>> driversState = const Loadable();
  String query = '';

  bool get canManageKyc =>
      _principal.can(AdminPermission.approveDriverKyc) ||
      _principal.can(AdminPermission.manageDrivers);

  bool get canTogglePresence => _principal.can(AdminPermission.controlDriverStatus);

  Future<void> refresh() async {
    driversState = driversState.copyWith(status: LoadStatus.loading, message: null);
    notifyListeners();
    try {
      final data = await _repository.listDrivers(query: query.isEmpty ? null : query);
      driversState = Loadable(status: LoadStatus.success, data: data);
    } catch (e) {
      driversState = Loadable(
        status: LoadStatus.failure,
        message: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> setSearch(String value) async {
    query = value;
    await refresh();
  }

  Future<void> blockDriver(String id) async {
    if (!canTogglePresence) return;
    await _repository.setPresence(id, DriverPresenceStatus.blocked);
    await refresh();
  }

  Future<void> approveKyc(String id) async {
    if (!canManageKyc) return;
    await _repository.setKyc(id, KycReviewStatus.approved);
    await refresh();
  }
}
