import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/shared/admin_staff_role.dart';
import '/shared/models/domain_enums.dart';
import '/modules/driver_management/repository/driver_admin_repository.dart';
import '/shared/providers/app_providers.dart';
import '/core/utils/view_state.dart';
import 'drivers_state.dart';

export 'drivers_state.dart';

/// ViewModel for the drivers list / management screen.
class DriversViewModel extends StateNotifier<DriversState> {
  DriversViewModel(this._repo, this._principal)
      : super(const DriversState());

  final DriverAdminRepository _repo;
  final AdminPrincipal _principal;

  bool get canManageKyc =>
      _principal.can(AdminPermission.approveDriverKyc) ||
      _principal.can(AdminPermission.manageDrivers);

  bool get canTogglePresence =>
      _principal.can(AdminPermission.controlDriverStatus);

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final data = await _repo.listDrivers(
          query: state.query.isEmpty ? null : state.query);
      state = state.copyWith(status: LoadStatus.success, drivers: data);
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(query: value);
    await refresh();
  }

  Future<void> blockDriver(String id) async {
    if (!canTogglePresence) return;
    await _repo.setPresence(id, DriverPresenceStatus.blocked);
    await refresh();
  }

  Future<void> approveKyc(String id) async {
    if (!canManageKyc) return;
    await _repo.setKyc(id, KycReviewStatus.approved);
    await refresh();
  }

  Future<void> rejectKyc(String id, String note) async {
    if (!canManageKyc) return;
    await _repo.setKyc(id, KycReviewStatus.rejected);
    await refresh();
  }
}

final _driversRepoProvider = Provider<DriverAdminRepository>((ref) {
  return ref.watch(adminDepsProvider).drivers;
});

/// Global drivers ViewModel provider.
final driversViewModelProvider =
    StateNotifierProvider<DriversViewModel, DriversState>((ref) {
  return DriversViewModel(
    ref.watch(_driversRepoProvider),
    ref.watch(adminPrincipalProvider),
  );
});
