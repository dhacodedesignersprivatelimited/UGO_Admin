import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/network/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../model/user_management_row.dart';

enum UserManagementTab { all, active, blocked }

class UserManagementViewModel extends ChangeNotifier {
  static const _kPageSizePrefKey = 'user_mgmt_page_size';
  static const _kTabPrefKey = 'user_mgmt_tab';
  static const _kSearchPrefKey = 'user_mgmt_search';
  static const _kPagePrefKey = 'user_mgmt_page';
  static const List<int> pageSizeOptions = [10, 20, 50];

  bool isLoading = true;
  String? errorMessage;
  UserManagementTab tab = UserManagementTab.all;
  int page = 1;
  int pageSize = 10;
  String searchQuery = '';
  List<UserManagementRow> pagedUsers = const [];
  int totalCount = 0;
  int totalActiveCount = 0;
  int totalBlockedCount = 0;
  final Set<int> actionUserIds = <int>{};
  final Map<UserManagementTab, int> _savedPageByTab = {};
  final Map<UserManagementTab, String> _savedSearchByTab = {};
  bool _prefsLoaded = false;

  Future<void> load() async {
    await _loadPrefsIfNeeded();
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    // Determine status filter based on selected tab
    String? statusFilter;
    if (tab == UserManagementTab.active) {
      statusFilter = 'active';
    } else if (tab == UserManagementTab.blocked) {
      statusFilter = 'blocked';
    }
    
    try {
      final res = await AllUsersCall.call(
        token: currentAuthenticationToken,
        page: page,
        limit: pageSize,
        status: statusFilter,
      );
      if (!res.succeeded) {
        isLoading = false;
        errorMessage = 'Could not load users';
        notifyListeners();
        return;
      }

      // Parse pagination info and users.
      final count = AllUsersCall.userall(res.jsonBody) ?? 0;

      // Update the appropriate count based on current tab.
      if (tab == UserManagementTab.all) {
        totalCount = count;
      } else if (tab == UserManagementTab.active) {
        totalActiveCount = count;
      } else if (tab == UserManagementTab.blocked) {
        totalBlockedCount = count;
      }

      pagedUsers = _toRows(_extractUsers(res.jsonBody));
      isLoading = false;
      notifyListeners();
    } catch (_) {
      isLoading = false;
      errorMessage = 'Could not load users';
      notifyListeners();
    }
  }

  Future<bool> toggleBlockUser(int userId) async {
    if (actionUserIds.contains(userId)) return false;
    actionUserIds.add(userId);
    notifyListeners();
    try {
      final user = pagedUsers.firstWhere((u) => u.id == userId);
      final res = user.isBlocked
          ? await UnblockUserCall.call(userId: userId, token: currentAuthenticationToken)
          : await BlockUserCall.call(userId: userId, token: currentAuthenticationToken);
      if (!res.succeeded) return false;
      await load();
      return true;
    } finally {
      actionUserIds.remove(userId);
      notifyListeners();
    }
  }

  void setTab(UserManagementTab value) {
    if (tab == value) return;
    tab = value;
    page = _savedPageByTab[value] ?? 1;
    searchQuery = _savedSearchByTab[value] ?? '';
    _saveTab();
    _savePage();
    unawaited(load());
  }

  void setSearchQuery(String value) {
    if (searchQuery == value) return;
    searchQuery = value;
    _savedSearchByTab[tab] = value;
    page = 1;
    _saveSearchQuery();
    _savePage();
    unawaited(load());
  }

  void previousPage() {
    if (page <= 1) return;
    page -= 1;
    _savePage();
    unawaited(load());
  }

  void nextPage() {
    if (page >= totalPages) return;
    page += 1;
    _savePage();
    unawaited(load());
  }

  void setPage(int value) {
    if (value < 1 || value > totalPages || value == page) return;
    page = value;
    _savePage();
    unawaited(load());
  }

  void setPageSize(int value) {
    if (!pageSizeOptions.contains(value) || value == pageSize) return;
    pageSize = value;
    page = 1;
    _savePageSize();
    _savePage();
    unawaited(load());
  }

  void resetAllTableState() {
    tab = UserManagementTab.all;
    page = 1;
    pageSize = pageSizeOptions.first;
    searchQuery = '';
    _savedSearchByTab[tab] = '';
    _saveTab();
    _savePage();
    _savePageSize();
    _saveSearchQuery();
    unawaited(load());
  }

  int get totalUsers => totalCount;
  int get activeUsers => totalActiveCount;
  int get blockedUsers => totalBlockedCount;

  int get totalPages {
    if (totalCount == 0) return 1;
    return (totalCount + pageSize - 1) ~/ pageSize;
  }

  int get startDisplay => pagedUsers.isEmpty ? 0 : ((page - 1) * pageSize) + 1;
  int get endDisplay => pagedUsers.isEmpty ? 0 : ((page - 1) * pageSize + pagedUsers.length);

  bool get hasNonDefaultTableState {
    return tab != UserManagementTab.all ||
        searchQuery.trim().isNotEmpty ||
        pageSize != pageSizeOptions.first ||
        page != 1;
  }

  List<Map<String, dynamic>> _extractUsers(dynamic body) {
    final raw = AllUsersCall.usersdata(body);
    if (raw is List) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  List<UserManagementRow> _toRows(List<Map<String, dynamic>> source) {
    final out = <UserManagementRow>[];
    for (var i = 0; i < source.length; i++) {
      final d = source[i];
      final id = _int(d['user_id'], fallback: i + 1);
      final name = (d['name'] ?? '').toString().trim();
      final phone = (d['phone'] ?? '').toString().trim();
      final email = (d['email'] ?? '').toString().trim();
      final rawAvatar = (d['profile_image'] ?? '').toString().trim();
      final avatar = rawAvatar.isEmpty || rawAvatar == 'null'
          ? ''
          : (rawAvatar.startsWith('http')
              ? rawAvatar
              : '${ApiConfig.baseUrl}/${rawAvatar.replaceFirst(RegExp(r'^/'), '')}');
      final walletBalance = (d['wallet_balance'] ?? 0).toString();
      final totalRides = _int(d['total_rides'], fallback: 0);
      // account_status can be "active", "blocked", etc.
      final accountStatus = (d['account_status'] ?? 'active').toString().trim().toLowerCase();
      final isBlocked = accountStatus == 'blocked';
      final status = isBlocked ? 'Blocked' : 'Active';
      final statusSubtitle = isBlocked ? 'By Admin' : 'Active';

      out.add(UserManagementRow(
        id: id,
        name: name,
        phone: phone,
        email: email,
        walletBalance: walletBalance,
        totalRides: totalRides,
        isBlocked: isBlocked,
        avatarUrl: avatar,
        status: status,
        statusSubtitle: statusSubtitle,
      ));
    }
    return out;
  }

  int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _bool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Future<void> _loadPrefsIfNeeded() async {
    if (_prefsLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    pageSize = prefs.getInt(_kPageSizePrefKey) ?? pageSizeOptions.first;
    tab = UserManagementTab.values[prefs.getInt(_kTabPrefKey) ?? 0];
    searchQuery = prefs.getString(_kSearchPrefKey) ?? '';
    page = prefs.getInt(_kPagePrefKey) ?? 1;
    _prefsLoaded = true;
  }

  Future<void> _savePageSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPageSizePrefKey, pageSize);
  }

  Future<void> _saveTab() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTabPrefKey, tab.index);
  }

  Future<void> _saveSearchQuery() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSearchPrefKey, searchQuery);
  }

  Future<void> _savePage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPagePrefKey, page);
  }
}