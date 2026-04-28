import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/user_management_repository.dart';
import 'user_management_state.dart';

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier(this._repository) : super(const UserManagementState());

  final UserManagementRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final users = await _repository.getUsers();
      state = state.copyWith(
        isLoading: false,
        allUsers: users,
        page: state.clampedPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setTab(UserManagementTab value) {
    if (state.tab == value) return;
    state = state.copyWith(tab: value, page: 1);
  }

  void setSearchQuery(String value) {
    if (state.searchQuery == value) return;
    state = state.copyWith(searchQuery: value, page: 1);
  }

  void previousPage() {
    if (state.clampedPage <= 1) return;
    state = state.copyWith(page: state.clampedPage - 1);
  }

  void nextPage() {
    if (state.clampedPage >= state.totalPages) return;
    state = state.copyWith(page: state.clampedPage + 1);
  }

  void setPage(int value) {
    if (value < 1 || value > state.totalPages || value == state.clampedPage) {
      return;
    }
    state = state.copyWith(page: value);
  }

  void setPageSize(int value) {
    if (!UserManagementState.pageSizeOptions.contains(value) ||
        value == state.pageSize) {
      return;
    }
    state = state.copyWith(pageSize: value, page: 1);
  }

  void resetAllTableState() {
    state = state.copyWith(
      tab: UserManagementTab.all,
      page: 1,
      pageSize: UserManagementState.pageSizeOptions.first,
      searchQuery: '',
    );
  }

  Future<bool> toggleBlockUser(int userId) async {
    if (state.actionUserIds.contains(userId)) return false;
    final nextActions = [...state.actionUserIds, userId];
    state = state.copyWith(actionUserIds: nextActions);

    try {
      final user = state.allUsers.firstWhere((u) => u.id == userId);
      if (user.isBlocked) {
        await _repository.unblockUser(userId);
      } else {
        await _repository.blockUser(userId);
      }
      await load();
      return true;
    } catch (_) {
      final cleanedActions = [...state.actionUserIds]..remove(userId);
      state = state.copyWith(actionUserIds: cleanedActions);
      return false;
    }
  }
}

final userManagementRepositoryProvider =
    Provider<UserManagementRepository>((ref) {
  return UserManagementRepository();
});

final userManagementNotifierProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  return UserManagementNotifier(ref.watch(userManagementRepositoryProvider));
});
