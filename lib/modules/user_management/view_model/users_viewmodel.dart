import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/modules/user_management/repository/user_admin_repository.dart';
import '/shared/providers/app_providers.dart';
import '/core/utils/view_state.dart';
import 'users_state.dart';

export 'users_state.dart';

/// ViewModel for the riders / users management screen.
class UsersViewModel extends StateNotifier<UsersState> {
  UsersViewModel(this._repo) : super(const UsersState());

  final UserAdminRepository _repo;

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final riders =
          await _repo.listRiders(query: state.query.isEmpty ? null : state.query);
      state = state.copyWith(status: LoadStatus.success, riders: riders);
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(query: value);
    await refresh();
  }

  Future<void> blockRider(String id) async {
    await _repo.setBlocked(id, true);
    await refresh();
  }

  Future<void> unblockRider(String id) async {
    await _repo.setBlocked(id, false);
    await refresh();
  }
}

final _usersRepoProvider = Provider<UserAdminRepository>((ref) {
  return ref.watch(adminDepsProvider).users;
});

/// Global users ViewModel provider.
final usersViewModelProvider =
    StateNotifierProvider<UsersViewModel, UsersState>((ref) {
  return UsersViewModel(ref.watch(_usersRepoProvider));
});
