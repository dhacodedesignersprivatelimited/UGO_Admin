import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '../models/analytics_models.dart';
import '../models/domain_enums.dart';
import '../models/driver_models.dart';
import '../models/finance_models.dart';
import '../models/notification_models.dart';
import '../models/promo_models.dart';
import '../models/rider_models.dart';
import '../models/ride_models.dart';
import '../models/settings_models.dart';
import '../models/vehicle_models.dart';
import 'admin_api_contract.dart';
import 'admin_api_exception.dart';
import 'http_admin_api_mappers.dart';

/// Bridges [AdminApiContract] to existing `ApiManager` / `*Call` classes.
/// Swap in for [MockAdminApiClient] when `tokenResolver` returns a JWT.
class HttpAdminApiClient implements AdminApiContract {
  HttpAdminApiClient({required this.tokenResolver});

  /// Return the admin Bearer token (same as `currentAuthenticationToken`).
  final String? Function() tokenResolver;

  String _token() {
    final t = tokenResolver();
    if (t == null || t.isEmpty) {
      throw AdminApiException('Not authenticated', statusCode: 401);
    }
    return t;
  }

  void _ensure(ApiCallResponse r, [String context = '']) {
    if (r.succeeded) return;
    final msg = getJsonField(r.jsonBody, r'''$.message''')?.toString() ??
        (r.bodyText.isNotEmpty ? r.bodyText : 'HTTP ${r.statusCode}');
    throw AdminApiException(
      context.isEmpty ? msg : '$context: $msg',
      statusCode: r.statusCode,
    );
  }

  int _parseIntId(String id, String label) {
    final v = int.tryParse(id.trim());
    if (v == null) {
      throw AdminApiException('Invalid $label id: $id');
    }
    return v;
  }

  List<dynamic> _driverListFromBody(dynamic jsonBody) {
    final direct = GetDriversCall.data(jsonBody);
    if (direct is List) return direct;
    final nested = getJsonField(jsonBody, r'''$.data.drivers''');
    if (nested is List) return nested;
    final alt = getJsonField(jsonBody, r'''$.drivers''');
    if (alt is List) return alt;
    return const [];
  }

  List<dynamic> _userListFromBody(dynamic jsonBody) {
    final direct = AllUsersCall.usersdata(jsonBody);
    if (direct is List) return direct;
    final data = getJsonField(jsonBody, r'''$.data.users''');
    if (data is List) return data;
    final alt = getJsonField(jsonBody, r'''$.users''');
    if (alt is List) return alt;
    return const [];
  }

  List<dynamic> _complaintsFromBody(dynamic jsonBody) {
    dynamic raw = jsonBody;
    if (raw is Map) {
      raw = getJsonField(raw, r'''$.data''') ?? getJsonField(raw, r'''$.complaints''');
    }
    if (raw is List) return raw;
    if (raw is Map) {
      final inner = raw['complaints'] ?? raw['rows'];
      if (inner is List) return inner;
    }
    return const [];
  }

  @override
  Future<DashboardAnalytics> fetchDashboardAnalytics() async {
    final r = await DashBoardCall.call(token: _token());
    _ensure(r, 'dashboard');
    final active = DashBoardCall.activedrivers(r.jsonBody) ?? 0;
    final today = DashBoardCall.todayrides(r.jsonBody) ?? 0;
    final totalRides = DashBoardCall.totalRides(r.jsonBody);
    final earnings = DashBoardCall.totalearnings(r.jsonBody);
    return DashboardAnalytics(
      generatedAt: DateTime.now(),
      metrics: [
        MetricTile(
          id: 'rides',
          title: 'Total rides',
          value: totalRides?.toString() ?? '—',
          deltaPercent: 0,
          trendUp: true,
        ),
        MetricTile(
          id: 'earnings',
          title: 'Total earnings',
          value: earnings != null ? '₹$earnings' : '—',
          deltaPercent: 0,
          trendUp: true,
        ),
        MetricTile(
          id: 'users',
          title: 'Total users',
          value: DashBoardCall.totalusers(r.jsonBody)?.toString() ?? '—',
          deltaPercent: 0,
          trendUp: true,
        ),
      ],
      activeDrivers: active,
      liveRides: 0,
      completedRides24h: today,
    );
  }

  @override
  Future<List<DriverListItem>> listDrivers({String? query}) async {
    final r = await GetDriversCall.call(token: _token());
    _ensure(r, 'drivers');
    final raw = _driverListFromBody(r.jsonBody);
    var items = <DriverListItem>[
      for (var i = 0; i < raw.length; i++) mapDriverRow(raw[i], i),
    ];
    final q = query?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      items = items
          .where(
            (d) =>
                d.displayName.toLowerCase().contains(q) ||
                d.phone.toLowerCase().contains(q),
          )
          .toList();
    }
    return items;
  }

  @override
  Future<DriverProfile> getDriver(String id) async {
    final intId = _parseIntId(id, 'driver');
    final r = await GetDriverByIdCall.call(token: _token(), id: intId);
    _ensure(r, 'driver');
    final d = GetDriverByIdCall.data(r.jsonBody);
    if (d is! Map) {
      throw AdminApiException('Invalid driver response');
    }
    final m = Map<String, dynamic>.from(d);
    final item = mapDriverRow(m, 0);
    final av = m['adminVehicle'];
    VehicleTypeRef type = const VehicleTypeRef(id: '0', name: '—');
    VehicleSubtypeRef sub = const VehicleSubtypeRef(id: '0', label: '—', vehicleTypeId: '0');
    var reg = '';
    var model = '';
    var color = '';
    var vehicleId = '0';
    if (av is Map) {
      final am = Map<String, dynamic>.from(av);
      vehicleId = castToType<int>(am['id'])?.toString() ?? '0';
      reg = _str(am['vehicle_number'] ?? am['registration_number']);
      model = _str(am['vehicle_model'] ?? am['vehicle_name'] ?? am['name']);
      color = _str(am['color']);
      final tid = castToType<int>(am['vehicle_type_id'] ?? am['type_id']) ?? 0;
      type = VehicleTypeRef(id: tid.toString(), name: _str(am['vehicle_type'] ?? 'Vehicle'));
      sub = VehicleSubtypeRef(
        id: castToType<int>(am['id'])?.toString() ?? '0',
        label: _str(am['subtype'] ?? model),
        vehicleTypeId: tid.toString(),
      );
    }
    final wallet = DriverWalletSummary(
      balance: _double(m['wallet_balance']) ?? 0,
      pendingWithdrawals: _double(m['pending_withdrawals']) ?? 0,
      lifetimeEarnings: _double(m['total_earnings']) ?? 0,
    );
    return DriverProfile(
      id: item.id,
      displayName: item.displayName,
      phone: item.phone,
      email: _str(m['email']),
      city: _str(m['preferred_city'] ?? m['city'] ?? ''),
      presence: item.presence,
      kycStatus: item.kycStatus,
      vehicle: DriverVehicle(
        id: vehicleId,
        registrationNumber: reg.isNotEmpty ? reg : '—',
        modelName: model.isNotEmpty ? model : item.vehicleLabel,
        color: color.isNotEmpty ? color : '—',
        type: type,
        subtype: sub,
      ),
      wallet: wallet,
      rating: item.rating,
      completedRides: castToType<int>(m['completed_rides']) ?? 0,
      avatarUrl: _str(m['profile_image']).isEmpty ? null : m['profile_image']?.toString(),
    );
  }

  double? _double(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  String _str(dynamic v) => v?.toString().trim() ?? '';

  @override
  Future<void> setDriverPresence(String driverId, DriverPresenceStatus status) async {
    final id = _parseIntId(driverId, 'driver');
    switch (status) {
      case DriverPresenceStatus.online:
        final r1 = await UpdateDriverCall.call(
          id: id,
          token: _token(),
          isOnline: true,
          isActive: true,
        );
        _ensure(r1, 'driver online');
        return;
      case DriverPresenceStatus.offline:
        final r2 = await UpdateDriverCall.call(
          id: id,
          token: _token(),
          isOnline: false,
          isActive: true,
        );
        _ensure(r2, 'driver offline');
        return;
      case DriverPresenceStatus.blocked:
        final r = await UpdateDriverCall.call(
          id: id,
          token: _token(),
          isActive: false,
          isOnline: false,
        );
        _ensure(r, 'block driver');
        return;
    }
  }

  @override
  Future<void> setDriverKycStatus(String driverId, KycReviewStatus status) async {
    final id = _parseIntId(driverId, 'driver');
    final verification = switch (status) {
      KycReviewStatus.approved => 'approved',
      KycReviewStatus.rejected => 'rejected',
      KycReviewStatus.pending => 'pending',
    };
    final r = await VerifyDocsCall.call(
      driverId: id,
      token: _token(),
      verificationStatus: verification,
    );
    _ensure(r, 'KYC');
  }

  @override
  Future<List<RiderListItem>> listRiders({String? query}) async {
    final r = await AllUsersCall.call(token: _token());
    _ensure(r, 'users');
    final raw = _userListFromBody(r.jsonBody);
    var items = <RiderListItem>[
      for (var i = 0; i < raw.length; i++) mapUserRow(raw[i], i),
    ];
    final q = query?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      items = items
          .where(
            (u) =>
                u.displayName.toLowerCase().contains(q) ||
                u.phone.toLowerCase().contains(q),
          )
          .toList();
    }
    return items;
  }

  @override
  Future<RiderProfile> getRider(String id) async {
    final intId = _parseIntId(id, 'user');
    final r = await GetUserByIdCall.call(id: intId, token: _token());
    _ensure(r, 'user');
    final data = GetUserByIdCall.data(r.jsonBody);
    if (data == null) {
      throw AdminApiException('User not found');
    }
    final m = Map<String, dynamic>.from(data);
    final item = mapUserRow(m, 0);
    return RiderProfile(
      id: item.id,
      displayName: item.displayName,
      phone: item.phone,
      email: _str(m['email']),
      wallet: RiderWallet(balance: item.walletBalance, currency: 'INR'),
      isBlocked: item.isBlocked,
      completedRides: castToType<int>(m['total_rides']) ?? 0,
      avatarUrl: _str(m['profile_image']).isEmpty ? null : m['profile_image']?.toString(),
    );
  }

  @override
  Future<void> setRiderBlocked(String riderId, bool blocked) async {
    final intId = _parseIntId(riderId, 'user');
    final r = blocked
        ? await BlockUserCall.call(token: _token(), userId: intId)
        : await UnblockUserCall.call(token: _token(), userId: intId);
    _ensure(r, blocked ? 'block user' : 'unblock user');
  }

  @override
  Future<List<RideSummary>> listRides({RideLifecycleStatus? filter}) async {
    final r = await GetRidesCall.call(token: _token());
    _ensure(r, 'rides');
    final list = GetRidesCall.data(r.jsonBody) ?? const [];
    var out = <RideSummary>[
      for (final row in list) mapRideRow(row),
    ];
    if (filter != null) {
      out = out.where((e) => e.status == filter).toList();
    }
    return out;
  }

  @override
  Future<RideDetail> getRide(String id) async {
    final rideInt = _parseIntId(id, 'ride');
    final r = await GetAdminRideDetailsCall.call(token: _token(), rideId: rideInt);
    _ensure(r, 'ride detail');
    final d = GetAdminRideDetailsCall.data(r.jsonBody);
    if (d is! Map) {
      throw AdminApiException('Invalid ride payload');
    }
    final m = Map<String, dynamic>.from(d);
    final summary = mapRideRow(m);
    double lat1 = _double(m['pickup_latitude'] ?? m['from_lat']) ?? 0;
    double lng1 = _double(m['pickup_longitude'] ?? m['from_lng']) ?? 0;
    double lat2 = _double(m['drop_latitude'] ?? m['to_lat']) ?? 0;
    double lng2 = _double(m['drop_longitude'] ?? m['to_lng']) ?? 0;
    return RideDetail(
      summary: summary,
      pickup: GeoPoint(latitude: lat1, longitude: lng1),
      drop: GeoPoint(latitude: lat2, longitude: lng2),
      routePolyline: _str(m['polyline'] ?? m['route_polyline']),
      commission: _double(m['commission_amount'] ?? m['commission']),
      surgeMultiplier: _double(m['surge_multiplier']),
    );
  }

  @override
  Future<void> assignDriverToRide({
    required String rideId,
    required String driverId,
  }) async {
    throw AdminApiException(
      'assignDriverToRide is not wired: add an admin dispatch endpoint to api_calls, then map it here.',
    );
  }

  @override
  Future<void> cancelRideAsAdmin(String rideId, {String? reason}) async {
    final rideInt = _parseIntId(rideId, 'ride');
    final body = '''
{"reason": "${escapeStringForJson(reason ?? 'Cancelled from UGO Admin')}"}''';
    final r = await ApiManager.instance.makeApiCall(
      callName: 'adminCancelRide',
      apiUrl: '${ApiConfig.apiBase}/admins/rides/$rideInt/cancel',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${_token()}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
    _ensure(r, 'cancel ride');
  }

  @override
  Future<List<WithdrawalRequest>> listWithdrawals({WithdrawalStatus? status}) async {
    final r = await GetAdminWithdrawRequestsCall.call(token: _token());
    _ensure(r, 'withdrawals');
    final rows = GetAdminWithdrawRequestsCall.requestsList(r.jsonBody)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(mapWithdrawalRow)
        .toList();
    if (status == null) return rows;
    return rows.where((w) => w.status == status).toList();
  }

  @override
  Future<void> decideWithdrawal({
    required String id,
    required WithdrawalStatus decision,
  }) async {
    final payoutId = _parseIntId(id, 'payout');
    if (decision == WithdrawalStatus.rejected) {
      final r = await PostAdminPayoutRejectCall.call(
        token: _token(),
        payoutId: payoutId,
        reason: 'Rejected from modular admin hub',
      );
      _ensure(r, 'reject payout');
      return;
    }
    if (decision != WithdrawalStatus.approved && decision != WithdrawalStatus.paid) {
      return;
    }
    final r = await MarkPayoutPaidCall.call(
      token: _token(),
      payoutId: payoutId,
      paymentReference: 'Admin panel',
    );
    _ensure(r, 'mark payout paid');
  }

  @override
  Future<List<RiderComplaint>> listComplaints({ComplaintStatus? status}) async {
    final r = await GetComplaintsCall.call(token: _token());
    _ensure(r, 'complaints');
    final raw = _complaintsFromBody(r.jsonBody);
    var out = <RiderComplaint>[
      for (final c in raw)
        if (c is Map) mapComplaintRow(Map<String, dynamic>.from(c)),
    ];
    if (status != null) {
      out = out.where((c) => c.status == status).toList();
    }
    return out;
  }

  @override
  Future<void> updateComplaintStatus(String id, ComplaintStatus status) async {
    final cid = _parseIntId(id, 'complaint');
    final s = switch (status) {
      ComplaintStatus.resolved => 'resolved',
      ComplaintStatus.inReview => 'in_review',
      ComplaintStatus.escalated => 'escalated',
      ComplaintStatus.open => 'open',
    };
    final r = await UpdateComplaintCall.call(
      token: _token(),
      complaintId: cid,
      status: s,
    );
    _ensure(r, 'update complaint');
  }

  @override
  Future<List<PromoCode>> listPromoCodes() async {
    final r = await GetPromoCodesCall.call(token: _token());
    _ensure(r, 'promo codes');
    final data = getJsonField(r.jsonBody, r'''$.data''');
    dynamic list = data is Map ? getJsonField(data, r'''$.promoCodes''') : null;
    list ??= getJsonField(r.jsonBody, r'''$.data.promoCodes''');
    if (list is! List) return const [];
    return [
      for (final p in list)
        if (p is Map) mapPromoRow(Map<String, dynamic>.from(p)),
    ];
  }

  @override
  Future<GlobalSettingsSnapshot> getGlobalSettings() async {
    final r = await GetFinanceSettingsCall.call(token: _token());
    _ensure(r, 'finance settings');
    final data = getJsonField(r.jsonBody, r'''$.data''');
    final m = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final commission = _double(m['admin_commission_percent']) ?? 18;
    return GlobalSettingsSnapshot(
      fare: FareSettings(
        baseFare: 0,
        perKm: 0,
        perMinute: 0,
        minimumFare: 0,
        platformCommissionPercent: commission,
        taxPercent: _double(m['tax_percent']) ?? 0,
      ),
      surgeBands: const [],
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateFareSettings(FareSettings settings) async {
    final r = await UpdateFinanceSettingsCall.call(
      token: _token(),
      adminCommissionPercent: settings.platformCommissionPercent,
    );
    _ensure(r, 'update finance settings');
  }

  @override
  Future<List<AdminNotificationJob>> listNotificationJobs() async {
    final r = await GetNotificationsCall.call(token: _token(), page: 1, pageSize: 50);
    if (!r.succeeded) return const [];
    dynamic raw = getJsonField(r.jsonBody, r'''$.data''');
    if (raw is Map) raw = raw['notifications'] ?? raw['items'] ?? raw['rows'];
    if (raw is! List) return const [];
    final jobs = <AdminNotificationJob>[];
    for (var i = 0; i < raw.length; i++) {
      final row = raw[i];
      if (row is! Map) continue;
      final m = Map<String, dynamic>.from(row);
      jobs.add(
        AdminNotificationJob(
          id: castToType<int>(m['id'])?.toString() ?? '$i',
          title: _str(m['title'] ?? m['subject'] ?? 'Notification'),
          status: _str(m['status'] ?? 'sent'),
          createdAt: DateTime.tryParse(_str(m['created_at'])) ?? DateTime.now(),
        ),
      );
    }
    return jobs;
  }

  @override
  Future<void> enqueueNotification(AdminNotificationDraft draft) async {
    final r = await SendBroadcastNotificationCall.call(
      token: _token(),
      title: draft.title,
      body: draft.body,
    );
    _ensure(r, 'send notification');
  }

  @override
  Future<List<VehicleTypeRef>> listVehicleTypes() async {
    final r = await GetVehicleTypesCall.call(token: _token());
    _ensure(r, 'vehicle types');
    dynamic raw = r.jsonBody;
    if (raw is Map) raw = getJsonField(raw, r'''$.data''');
    if (raw == null && r.jsonBody is Map) {
      raw = getJsonField(r.jsonBody, r'''$.vehicle_types''') ??
          getJsonField(r.jsonBody, r'''$.vehicleTypes''');
    }
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map) mapVehicleTypeRow(Map<String, dynamic>.from(item)),
    ];
  }
}
