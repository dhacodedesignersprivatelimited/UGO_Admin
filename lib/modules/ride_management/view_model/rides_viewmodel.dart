import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/modules/ride_management/repository/rides_admin_repository.dart';
import '/shared/providers/app_providers.dart';
import '/core/utils/view_state.dart';
import 'rides_state.dart';

export 'rides_state.dart';

/// ViewModel for the rides management screen.
class RidesViewModel extends StateNotifier<RidesState> {
  RidesViewModel(this._repo) : super(const RidesState());

  final RidesAdminRepository _repo;

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final rides = await _repo.listRides();
      state = state.copyWith(status: LoadStatus.success, rides: rides);
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  void setSearch(String value) => state = state.copyWith(query: value);

  void setStatusFilter(String? statusValue) {
    state = state.copyWith(
      statusFilter: statusValue,
      clearStatusFilter: statusValue == null,
    );
  }
}

final _ridesRepoProvider = Provider<RidesAdminRepository>((ref) {
  return ref.watch(adminDepsProvider).rides;
});

/// Global rides ViewModel provider.
final ridesViewModelProvider =
    StateNotifierProvider<RidesViewModel, RidesState>((ref) {
  return RidesViewModel(ref.watch(_ridesRepoProvider));
});
