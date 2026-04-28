import '../models/user_management_row.dart';

enum UserManagementTab { all, active, blocked }

class UserManagementState {
  const UserManagementState({
    this.isLoading = true,
    this.errorMessage,
    this.tab = UserManagementTab.all,
    this.page = 1,
    this.pageSize = 10,
    this.searchQuery = '',
    this.allUsers = const [],
    this.actionUserIds = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final UserManagementTab tab;
  final int page;
  final int pageSize;
  final String searchQuery;
  final List<UserManagementRow> allUsers;
  final List<int> actionUserIds;

  static const List<int> pageSizeOptions = [10, 20, 50];

  int get totalUsers => allUsers.length;
  int get activeUsers => allUsers.where((e) => !e.isBlocked).length;
  int get blockedUsers => allUsers.where((e) => e.isBlocked).length;

  List<UserManagementRow> get filteredUsers {
    final base = switch (tab) {
      UserManagementTab.all => allUsers,
      UserManagementTab.active => allUsers.where((e) => !e.isBlocked).toList(),
      UserManagementTab.blocked => allUsers.where((e) => e.isBlocked).toList(),
    };
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return base;
    return base.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.phone.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          e.id.toString().contains(q);
    }).toList();
  }

  int get totalPages {
    final total = filteredUsers.length;
    if (total == 0) return 1;
    return (total + pageSize - 1) ~/ pageSize;
  }

  int get clampedPage => page.clamp(1, totalPages);

  List<UserManagementRow> get pagedUsers {
    final list = filteredUsers;
    if (list.isEmpty) return const [];
    final start = (clampedPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get startDisplay => filteredUsers.isEmpty ? 0 : ((clampedPage - 1) * pageSize) + 1;
  int get endDisplay => filteredUsers.isEmpty ? 0 : ((clampedPage - 1) * pageSize + pagedUsers.length);

  bool get hasNonDefaultTableState {
    return tab != UserManagementTab.all ||
        searchQuery.trim().isNotEmpty ||
        pageSize != pageSizeOptions.first ||
        page != 1;
  }

  UserManagementState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    UserManagementTab? tab,
    int? page,
    int? pageSize,
    String? searchQuery,
    List<UserManagementRow>? allUsers,
    List<int>? actionUserIds,
  }) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      tab: tab ?? this.tab,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
      allUsers: allUsers ?? this.allUsers,
      actionUserIds: actionUserIds ?? this.actionUserIds,
    );
  }
}
