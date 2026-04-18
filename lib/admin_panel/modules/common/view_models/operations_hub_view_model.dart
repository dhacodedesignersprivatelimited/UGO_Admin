import 'package:flutter/foundation.dart';

import '../../../core/admin_staff_role.dart';
import '../../../core/loadable.dart';
import '../../../data/models/ride_models.dart';
import '../../../data/repositories/rides_admin_repository.dart';

class OperationsHubViewModel extends ChangeNotifier {
  OperationsHubViewModel({
    required RidesAdminRepository repository,
    required AdminPrincipal principal,
  })  : _repository = repository,
        _principal = principal;

  final RidesAdminRepository _repository;
  final AdminPrincipal _principal;

  Loadable<List<RideSummary>> ridesState = const Loadable();

  bool get canManageRides => _principal.can(AdminPermission.manageRidesLive);

  Future<void> refresh() async {
    ridesState = ridesState.copyWith(status: LoadStatus.loading);
    notifyListeners();
    try {
      final data = await _repository.listRides();
      ridesState = Loadable(status: LoadStatus.success, data: data);
    } catch (e) {
      ridesState = Loadable(status: LoadStatus.failure, message: e.toString());
    }
    notifyListeners();
  }

  Future<void> quickAssign(String rideId, String driverId) async {
    if (!canManageRides) return;
    await _repository.assignDriver(rideId: rideId, driverId: driverId);
    await refresh();
  }

  Future<void> cancel(String rideId) async {
    if (!canManageRides) return;
    await _repository.cancel(rideId, reason: 'Cancelled from control room');
    await refresh();
  }
}
