import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver_management_row.dart';

enum DriverManagementTab { all, active, online, pending, blocked }

class DriverManagementViewModel extends ChangeNotifier {
  static const _kPageSizePrefKey = 'driver_mgmt_page_size';
  static const _kTabPrefKey = 'driver_mgmt_tab';
  static const _kSearchPrefKey = 'driver_mgmt_search';
  static const _kPagePrefKey = 'driver_mgmt_page'; // legacy fallback
  static const List<int> pageSizeOptions = [10, 25, 50];

  bool isLoading = true;
  String? errorMessage;
  DriverManagementTab tab = DriverManagementTab.all;
  int page = 1;
  int pageSize = 10;
  String searchQuery = '';
  List<DriverManagementRow> allDrivers = const [];
  final Set<int> actionDriverIds = <int>{};
  final Map<DriverManagementTab, int> _savedPageByTab = {};
  final Map<DriverManagementTab, String> _savedSearchByTab = {};
  bool _prefsLoaded = false;

  Future<void> load() async {
    await _loadPrefsIfNeeded();
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final res = await GetDriversCall.call(token: currentAuthenticationToken);
    if (!res.succeeded) {
      isLoading = false;
      errorMessage = 'Could not load drivers';
      notifyListeners();
      return;
    }
    allDrivers = _toRows(_extractDrivers(res.jsonBody));
    isLoading = false;
    notifyListeners();
  }

  Future<bool> approveDriver(int driverId) async {
    if (actionDriverIds.contains(driverId)) return false;
    actionDriverIds.add(driverId);
    notifyListeners();
    try {
      final res = await VerifyDocsCall.call(
        driverId: driverId,
        verificationStatus: 'approved',
        token: currentAuthenticationToken,
      );
      if (!res.succeeded) return false;
      await load();
      return true;
    } finally {
      actionDriverIds.remove(driverId);
      notifyListeners();
    }
  }

  Future<bool> rejectDriver(int driverId) async {
    if (actionDriverIds.contains(driverId)) return false;
    actionDriverIds.add(driverId);
    notifyListeners();
    try {
      final res = await VerifyDocsCall.call(
        driverId: driverId,
        verificationStatus: 'rejected',
        token: currentAuthenticationToken,
      );
      if (!res.succeeded) return false;
      await load();
      return true;
    } finally {
      actionDriverIds.remove(driverId);
      notifyListeners();
    }
  }

  void setTab(DriverManagementTab value) {
    if (tab == value) return;
    tab = value;
    page = _savedPageByTab[value] ?? 1;
    searchQuery = _savedSearchByTab[value] ?? '';
    _saveTab();
    _savePage();
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (searchQuery == value) return;
    searchQuery = value;
    _savedSearchByTab[tab] = value;
    page = 1;
    _saveSearchQuery();
    _savePage();
    notifyListeners();
  }

  void previousPage() {
    if (page <= 1) return;
    page -= 1;
    _savePage();
    notifyListeners();
  }

  void nextPage() {
    if (page >= totalPages) return;
    page += 1;
    _savePage();
    notifyListeners();
  }

  void setPage(int value) {
    if (value < 1 || value > totalPages || value == page) return;
    page = value;
    _savePage();
    notifyListeners();
  }

  void setPageSize(int value) {
    if (!pageSizeOptions.contains(value) || value == pageSize) return;
    pageSize = value;
    page = 1;
    _savePageSize();
    _savePage();
    notifyListeners();
  }

  void resetAllTableState() {
    tab = DriverManagementTab.all;
    page = 1;
    pageSize = pageSizeOptions.first;
    searchQuery = '';
    _savedSearchByTab[tab] = '';
    _saveTab();
    _savePage();
    _savePageSize();
    _saveSearchQuery();
    notifyListeners();
  }

  int get totalDrivers => allDrivers.length;
  int get activeDrivers => allDrivers.where((e) => e.status == 'Active').length;
  int get onlineDrivers => allDrivers.where((e) => e.isOnline).length;
  int get pendingDrivers => allDrivers.where((e) => e.isPending).length;
  int get blockedDrivers => allDrivers.where((e) => e.isBlocked).length;

  List<DriverManagementRow> get filteredDrivers {
    final base = switch (tab) {
      DriverManagementTab.all => allDrivers,
      DriverManagementTab.active => allDrivers.where((e) => e.status == 'Active').toList(),
      DriverManagementTab.online => allDrivers.where((e) => e.isOnline).toList(),
      DriverManagementTab.pending => allDrivers.where((e) => e.isPending).toList(),
      DriverManagementTab.blocked => allDrivers.where((e) => e.isBlocked).toList(),
    };
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return base;
    return base.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.phone.toLowerCase().contains(q) ||
          e.id.toString().contains(q);
    }).toList();
  }

  int get totalPages {
    final total = filteredDrivers.length;
    if (total == 0) return 1;
    return (total + pageSize - 1) ~/ pageSize;
  }

  int get clampedPage => page.clamp(1, totalPages);

  List<DriverManagementRow> get pagedDrivers {
    final list = filteredDrivers;
    if (list.isEmpty) return const [];
    final start = (clampedPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get startDisplay => filteredDrivers.isEmpty ? 0 : ((clampedPage - 1) * pageSize) + 1;
  int get endDisplay => filteredDrivers.isEmpty ? 0 : ((clampedPage - 1) * pageSize + pagedDrivers.length);

  List<DriverManagementRow> get topPending => allDrivers.where((e) => e.isPending).take(3).toList();

  int get verifiedDrivingLicense => allDrivers.where((e) => e.hasLicense).length;
  int get verifiedRcBook => allDrivers.where((e) => e.hasRcBook).length;
  int get verifiedAadhaar => allDrivers.where((e) => e.hasAadhaar).length;
  int get verifiedProfile => allDrivers.where((e) => e.hasProfile).length;

  bool get hasNonDefaultTableState {
    return tab != DriverManagementTab.all ||
        searchQuery.trim().isNotEmpty ||
        pageSize != pageSizeOptions.first ||
        page != 1;
  }

  int countForTab(DriverManagementTab t) => switch (t) {
        DriverManagementTab.all => totalDrivers,
        DriverManagementTab.active => activeDrivers,
        DriverManagementTab.online => onlineDrivers,
        DriverManagementTab.pending => pendingDrivers,
        DriverManagementTab.blocked => blockedDrivers,
      };

  List<Map<String, dynamic>> _extractDrivers(dynamic body) {
    final raw = GetDriversCall.data(body);
    if (raw is List) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  List<DriverManagementRow> _toRows(List<Map<String, dynamic>> source) {
    final out = <DriverManagementRow>[];
    for (var i = 0; i < source.length; i++) {
      final d = source[i];
      final id = _int(d['id'], fallback: i + 1);
      final status = _status(d);
      final first = (d['first_name'] ?? '').toString().trim();
      final last = (d['last_name'] ?? '').toString().trim();
      final name = ('$first $last').trim().isEmpty ? 'Driver #$id' : ('$first $last').trim();
      final phone = (d['mobile_number'] ?? '').toString().trim();
      final rawAvatar = (d['profile_image'] ?? '').toString().trim();
      final avatar = rawAvatar.isEmpty || rawAvatar == 'null'
          ? ''
          : (rawAvatar.startsWith('http')
              ? rawAvatar
              : '${ApiConfig.baseUrl}/${rawAvatar.replaceFirst(RegExp(r'^/'), '')}');
      final vehicle = (d['vehicle_type'] ??
              d['vehicle_number'] ??
              d['adminVehicle']?['vehicle_name'] ??
              'Auto')
          .toString();
      final vehicleNumber = (d['vehicle_number'] ??
              d['adminVehicle']?['vehicle_number'] ??
              d['adminVehicle']?['plate_number'] ??
              '')
          .toString();
      final isOnline = _bool(d['is_online']) || _bool(d['online']);
      final statusSubtitle = switch (status) {
        'Active' => isOnline ? 'Online' : 'Offline',
        'Pending' => 'Approval',
        'Blocked' => 'By Admin',
        _ => '',
      };
      final walletBalance = _money(
        d['wallet_balance'] ?? d['balance'] ?? d['total_earnings'] ?? d['earnings'],
      );
      final hasLicense = _hasAny(d, ['driving_licence_image', 'driving_license_image', 'license_image']);
      final hasRc = _hasAny(d, ['rc_book_image', 'rc_image', 'vehicle_rc']);
      final hasAadhaar = _hasAny(d, ['aadhaar_front_image', 'aadhaar_back_image', 'aadhaar_image']);
      final hasProfile = _hasAny(d, ['profile_image']);
      out.add(
        DriverManagementRow(
          id: id,
          name: name,
          phone: phone,
          vehicle: vehicle,
          vehicleNumber: vehicleNumber,
          avatarUrl: avatar,
          status: status,
          statusSubtitle: statusSubtitle,
          walletBalance: walletBalance,
          totalRides: _int(d['completed_rides'] ?? d['total_trips'] ?? d['ride_count']),
          rating: _double(d['rating'] ?? d['avg_rating'], fallback: 4),
          isOnline: isOnline,
          isPending: status == 'Pending',
          isBlocked: status == 'Blocked',
          hasLicense: hasLicense,
          hasRcBook: hasRc,
          hasAadhaar: hasAadhaar,
          hasProfile: hasProfile,
          appliedAt: _date(d['created_at']) ?? _date(d['updated_at']),
        ),
      );
    }
    out.sort((a, b) {
      final ad = a.appliedAt;
      final bd = b.appliedAt;
      if (ad != null && bd != null) return bd.compareTo(ad);
      return b.id.compareTo(a.id);
    });
    return out;
  }

  String _status(Map<String, dynamic> d) {
    final kyc = (d['kyc_status'] ?? '').toString().toLowerCase();
    final blocked = _bool(d['is_blocked']) || (d['status']?.toString().toLowerCase() == 'blocked');
    final active = _bool(d['is_active']) || _bool(d['active_driver']);
    if (blocked || kyc == 'rejected' || kyc == 'declined') return 'Blocked';
    if (kyc == 'pending' || kyc.isEmpty) return 'Pending';
    if (active) return 'Active';
    return 'Inactive';
  }

  bool _hasAny(Map<String, dynamic> d, List<String> keys) {
    for (final k in keys) {
      final v = (d[k] ?? '').toString().trim();
      if (v.isNotEmpty && v != 'null') return true;
    }
    return false;
  }

  bool _bool(dynamic v) {
    final s = (v ?? '').toString().toLowerCase().trim();
    return s == 'true' || s == '1' || s == 'yes';
  }

  int _int(dynamic v, {int fallback = 0}) => int.tryParse((v ?? '').toString()) ?? fallback;
  double _double(dynamic v, {double fallback = 0}) => double.tryParse((v ?? '').toString()) ?? fallback;
  String _money(dynamic v) {
    final n = _double(v, fallback: 0);
    final fmt = NumberFormat('#,##0.00', 'en_IN');
    return '₹${fmt.format(n)}';
  }
  DateTime? _date(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadPrefsIfNeeded() async {
    if (_prefsLoaded) return;
    _prefsLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt(_kPageSizePrefKey);
      if (stored != null && pageSizeOptions.contains(stored)) {
        pageSize = stored;
      }
      final tabIndex = prefs.getInt(_kTabPrefKey);
      if (tabIndex != null &&
          tabIndex >= 0 &&
          tabIndex < DriverManagementTab.values.length) {
        tab = DriverManagementTab.values[tabIndex];
      }
      final q = prefs.getString(_kSearchPrefKey);
      if (q != null) {
        searchQuery = q;
      }
      for (final t in DriverManagementTab.values) {
        final sq = prefs.getString(_searchKeyForTab(t));
        if (sq != null) {
          _savedSearchByTab[t] = sq;
        }
      }
      searchQuery = _savedSearchByTab[tab] ?? searchQuery;
      final storedPage = prefs.getInt(_kPagePrefKey);
      if (storedPage != null && storedPage > 0) {
        page = storedPage;
      }
      for (final t in DriverManagementTab.values) {
        final p = prefs.getInt(_pageKeyForTab(t));
        if (p != null && p > 0) {
          _savedPageByTab[t] = p;
        }
      }
      page = _savedPageByTab[tab] ?? page;
    } catch (_) {}
  }

  Future<void> _savePageSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kPageSizePrefKey, pageSize);
    } catch (_) {}
  }

  Future<void> _saveTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kTabPrefKey, tab.index);
    } catch (_) {}
  }

  Future<void> _saveSearchQuery() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSearchPrefKey, searchQuery);
      await prefs.setString(_searchKeyForTab(tab), searchQuery);
    } catch (_) {}
  }

  Future<void> _savePage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedPageByTab[tab] = page;
      await prefs.setInt(_kPagePrefKey, page);
      await prefs.setInt(_pageKeyForTab(tab), page);
    } catch (_) {}
  }

  String _pageKeyForTab(DriverManagementTab tab) => 'driver_mgmt_page_${tab.name}';
  String _searchKeyForTab(DriverManagementTab tab) =>
      'driver_mgmt_search_${tab.name}';
}
