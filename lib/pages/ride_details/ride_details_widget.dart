import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_config.dart';
import '/components/admin_drawer.dart';
import '/pages/finance_control/finance_control_hub_widget.dart';
import '/components/admin_pop_scope.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailsWidget extends StatefulWidget {
  const RideDetailsWidget({super.key, required this.rideId});

  final int? rideId;

  static String routeName = 'RideDetails';
  static String routePath = '/ride-details';

  @override
  State<RideDetailsWidget> createState() => _RideDetailsWidgetState();
}

class _RideDetailsWidgetState extends State<RideDetailsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  Map<String, dynamic>? _ride;
  /// `true` when loaded from [GetAdminRideDetailsCall] (full record).
  bool _fromAdminApi = false;
  String? _errorMessage;

  /// From [GetUserByIdCall] / [GetDriverByIdCall] using ride `user_id` / `driver_id`.
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _driverProfile;
  bool _profilesLoading = false;

  static const _hiddenExactKeys = {
    'password',
    'otp_hash',
  };

  /// Substrings in field names to hide from admin UI (tokens, push, secrets).
  static const _hiddenKeyFragments = [
    'fcm_token',
    'fcm',
    'device_token',
    'push_token',
    'apns_token',
    'apns',
    'refresh_token',
    'api_key',
    'secret_key',
  ];

  bool _isHiddenKey(String key) {
    final k = key.toLowerCase().trim();
    if (_hiddenExactKeys.contains(k)) return true;
    for (final frag in _hiddenKeyFragments) {
      if (k.contains(frag)) return true;
    }
    return false;
  }

  /// True if [r] has at least one non-empty value for any of [keys].
  bool _hasSupportFields(Map<String, dynamic> r, List<String> keys) {
    for (final k in keys) {
      if (!r.containsKey(k)) continue;
      final v = r[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isEmpty || s == 'null') continue;
      return true;
    }
    return false;
  }

  int? _partyUserId(Map<String, dynamic> r) {
    final v = r['user_id'] ?? r['rider_id'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  int? _partyDriverId(Map<String, dynamic> r) {
    final v = r['driver_id'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(int id, String token) async {
    final resp = await GetUserByIdCall.call(id: id, token: token);
    if (!resp.succeeded) return null;
    final d = GetUserByIdCall.data(resp.jsonBody);
    if (d == null) return null;
    final m = Map<String, dynamic>.from(d);
    m.remove('password');
    return m;
  }

  Future<Map<String, dynamic>?> _fetchDriverProfile(int id, String token) async {
    final resp = await GetDriverByIdCall.call(id: id, token: token);
    if (!resp.succeeded) return null;
    return _coerceMap(GetDriverByIdCall.data(resp.jsonBody));
  }

  Future<void> _fetchPartyProfiles(Map<String, dynamic> ride, String token) async {
    if (!mounted || token.isEmpty) return;
    final uid = _partyUserId(ride);
    final did = _partyDriverId(ride);
    if (uid == null && did == null) return;

    setState(() => _profilesLoading = true);
    try {
      final results = await Future.wait([
        uid != null ? _fetchUserProfile(uid, token) : Future<Map<String, dynamic>?>.value(null),
        did != null ? _fetchDriverProfile(did, token) : Future<Map<String, dynamic>?>.value(null),
      ]);
      if (!mounted) return;
      setState(() {
        _userProfile = results[0];
        _driverProfile = results[1];
        _profilesLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _profilesLoading = false);
      }
    }
  }

  /// Rider nested `user`, or root-level fields from [GetRideByIdCall] (`first_name`, `mobile_number`, …).
  Map<String, dynamic>? _riderPayloadFromRideOnly(Map<String, dynamic> r) {
    final u = _coerceMap(r['user']);
    if (u != null && u.isNotEmpty) return u;
    final uid = r['user_id'];
    final fn = r['first_name'];
    final ln = r['last_name'];
    final mn = r['mobile_number'];
    if (uid == null && fn == null && ln == null && mn == null) return null;
    return {
      if (uid != null) 'id': uid,
      if (fn != null && fn.toString().trim().isNotEmpty) 'first_name': fn,
      if (ln != null && ln.toString().trim().isNotEmpty) 'last_name': ln,
      if (mn != null && mn.toString().trim().isNotEmpty) 'mobile_number': mn,
    };
  }

  Map<String, dynamic>? _riderPayloadForCard(Map<String, dynamic> r) {
    if (_userProfile != null && _userProfile!.isNotEmpty) {
      return _userProfile;
    }
    return _riderPayloadFromRideOnly(r);
  }

  Map<String, dynamic>? _driverPayloadFromRideOnly(Map<String, dynamic> r) {
    final d = _coerceMap(r['driver']);
    if (d != null && d.isNotEmpty) return d;
    final id = r['driver_id'];
    final name = r['driver_name']?.toString().trim();
    final phone = r['driver_phone']?.toString().trim();
    final img = r['driver_profile_image']?.toString().trim();
    if (id == null &&
        (name == null || name.isEmpty || name == 'null') &&
        (phone == null || phone.isEmpty || phone == 'null')) {
      return null;
    }
    return {
      if (id != null) 'id': id,
      if (name != null && name.isNotEmpty && name != 'null') 'name': name,
      if (phone != null && phone.isNotEmpty && phone != 'null')
        'mobile_number': phone,
      if (img != null && img.isNotEmpty && img != 'null')
        'profile_image': img,
      if (r['driver_rating'] != null) 'driver_rating': r['driver_rating'],
      if (r['driver_total_rides'] != null)
        'total_rides_completed': r['driver_total_rides'],
    };
  }

  Map<String, dynamic>? _driverPayloadForCard(Map<String, dynamic> r) {
    if (_driverProfile != null && _driverProfile!.isNotEmpty) {
      return _driverProfile;
    }
    return _driverPayloadFromRideOnly(r);
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchAllDetails());
  }

  Future<void> _fetchAllDetails() async {
    if (widget.rideId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid ride ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _ride = null;
      _userProfile = null;
      _driverProfile = null;
      _profilesLoading = false;
    });

    final token = currentAuthenticationToken ?? '';

    try {
      final adminResp = await GetAdminRideDetailsCall.call(
        token: token,
        rideId: widget.rideId!,
      );
      if (adminResp.succeeded) {
        final raw = GetAdminRideDetailsCall.data(adminResp.jsonBody);
        final m = _coerceMap(raw);
        if (m != null && mounted) {
          setState(() {
            _ride = m;
            _fromAdminApi = true;
            _isLoading = false;
          });
          await _fetchPartyProfiles(m, token);
          return;
        }
      }

      final rideResp = await GetRideByIdCall.call(
        token: token,
        rideId: widget.rideId!,
      );
      if (!rideResp.succeeded) {
        final msg = getJsonField(rideResp.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to load ride (${rideResp.statusCode})';
        if (mounted) {
          setState(() {
            _errorMessage = msg;
            _isLoading = false;
          });
        }
        return;
      }

      final raw = GetRideByIdCall.data(rideResp.jsonBody);
      final m = _coerceMap(raw);
      if (mounted) {
        setState(() {
          _ride = m;
          _fromAdminApi = false;
          _isLoading = false;
        });
        if (m != null) await _fetchPartyProfiles(m, token);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _riderDisplayName(Map<String, dynamic> r) {
    final prof = _userProfile;
    if (prof != null) {
      final nm = prof['name']?.toString().trim();
      if (nm != null && nm.isNotEmpty && nm != 'null') return nm;
      final fn = prof['first_name']?.toString() ?? '';
      final ln = prof['last_name']?.toString() ?? '';
      final c = '$fn $ln'.trim();
      if (c.isNotEmpty) return c;
    }
    final u = _coerceMap(r['user']);
    if (u != null) {
      final fn = u['first_name']?.toString() ?? '';
      final ln = u['last_name']?.toString() ?? '';
      final c = '$fn $ln'.trim();
      if (c.isNotEmpty) return c;
    }
    for (final k in [
      'rider_name',
      'user_name',
      'passenger_name',
      'first_name',
    ]) {
      final v = r[k]?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    final id = r['user_id'] ?? r['rider_id'];
    return id != null ? 'User #$id' : 'Rider';
  }

  String? _riderPhone(Map<String, dynamic> r) {
    final prof = _userProfile;
    if (prof != null) {
      for (final k in ['mobile_number', 'phone']) {
        final p = prof[k]?.toString().trim();
        if (p != null && p.isNotEmpty && p != 'null') return p;
      }
    }
    final u = _coerceMap(r['user']);
    if (u != null) {
      final p = u['mobile_number']?.toString().trim();
      if (p != null && p.isNotEmpty && p != 'null') return p;
    }
    for (final k in ['mobile_number', 'rider_phone', 'user_phone']) {
      final p = r[k]?.toString().trim();
      if (p != null && p.isNotEmpty && p != 'null') return p;
    }
    return null;
  }

  String _driverDisplayName(Map<String, dynamic> r) {
    final prof = _driverProfile;
    if (prof != null) {
      final nm = prof['name']?.toString().trim();
      if (nm != null && nm.isNotEmpty && nm != 'null') return nm;
      final fn = prof['first_name']?.toString() ?? '';
      final ln = prof['last_name']?.toString() ?? '';
      final c = '$fn $ln'.trim();
      if (c.isNotEmpty) return c;
    }
    final d = _coerceMap(r['driver']);
    if (d != null) {
      final fn = d['first_name']?.toString() ?? '';
      final ln = d['last_name']?.toString() ?? '';
      final c = '$fn $ln'.trim();
      if (c.isNotEmpty) return c;
    }
    final n = r['driver_name']?.toString().trim();
    if (n != null && n.isNotEmpty && n != 'null') return n;
    final id = r['driver_id'];
    return id != null ? 'Driver #$id' : '—';
  }

  String? _driverPhone(Map<String, dynamic> r) {
    final prof = _driverProfile;
    if (prof != null) {
      for (final k in ['mobile_number', 'phone']) {
        final p = prof[k]?.toString().trim();
        if (p != null && p.isNotEmpty && p != 'null') return p;
      }
    }
    final d = _coerceMap(r['driver']);
    if (d != null) {
      final p = d['mobile_number']?.toString().trim();
      if (p != null && p.isNotEmpty && p != 'null') return p;
    }
    final p = r['driver_phone']?.toString().trim();
    if (p != null && p.isNotEmpty && p != 'null') return p;
    return null;
  }

  String? _riderPhotoUrl(Map<String, dynamic> r) {
    String? raw = _userProfile?['profile_image']?.toString();
    raw ??= _coerceMap(r['user'])?['profile_image']?.toString();
    for (final k in [
      'rider_profile_image',
      'user_profile_image',
      'passenger_image',
      'profile_image',
    ]) {
      raw ??= r[k]?.toString();
    }
    final u = _resolveImageUrl(raw);
    return u.isEmpty ? null : u;
  }

  String? _driverPhotoUrl(Map<String, dynamic> r) {
    String? raw = _driverProfile?['profile_image']?.toString();
    raw ??= _coerceMap(r['driver'])?['profile_image']?.toString();
    raw ??= r['driver_profile_image']?.toString();
    final u = _resolveImageUrl(raw);
    return u.isEmpty ? null : u;
  }

  Future<void> _copy(String label, String? text) async {
    if (text == null || text.isEmpty || text == '—') return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied'), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _dial(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'\s'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openContactSheet() {
    final r = _ride;
    if (r == null) return;
    final rp = _riderPhone(r);
    final dp = _driverPhone(r);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Contact',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (rp != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Rider'),
                    subtitle: Text(rp),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () => _dial(rp),
                    ),
                  ),
                if (dp != null)
                  ListTile(
                    leading: const Icon(Icons.local_taxi_outlined),
                    title: const Text('Driver'),
                    subtitle: Text(dp),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () => _dial(dp),
                    ),
                  ),
                if (rp == null && dp == null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No phone numbers on this ride record.',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminPopScope(
      child: Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      drawer: buildAdminDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.white,
        title: Text(
          'Ride details',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.rideId != null)
            IconButton(
              tooltip: 'Ledger (this ride)',
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () {
                context.pushNamed(
                  FinanceControlHubWidget.routeName,
                  queryParameters: {
                    'tab': '1',
                    'rideId': '${widget.rideId}',
                  },
                );
              },
            ),
          if (_ride != null)
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _fetchAllDetails,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.error),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: theme.secondaryText),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _fetchAllDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _ride == null
                  ? const Center(child: Text('No data'))
                  : _buildBody(context, theme),
      floatingActionButton: _ride == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.white,
              onPressed: _openContactSheet,
              icon: const Icon(Icons.phone),
              label: const Text('Contact'),
            ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FlutterFlowTheme theme) {
    final r = _ride!;
    return RefreshIndicator(
      onRefresh: _fetchAllDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, r, theme)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.08),
            _sectionCard(
              context,
              theme,
              'Trip',
              Icons.route_rounded,
              [
                _kv(context, theme, 'Pickup', r['pickup_location_address'], multiline: true),
                _kv(context, theme, 'Drop-off', r['drop_location_address'], multiline: true),
                _kv(context, theme, 'Pickup lat / lng',
                    '${_display(r['pickup_latitude'])} , ${_display(r['pickup_longitude'])}',
                    copyValue:
                        '${_display(r['pickup_latitude'])},${_display(r['pickup_longitude'])}'),
                _kv(context, theme, 'Drop lat / lng',
                    '${_display(r['drop_latitude'])} , ${_display(r['drop_longitude'])}',
                    copyValue:
                        '${_display(r['drop_latitude'])},${_display(r['drop_longitude'])}'),
                _kv(context, theme, 'Distance (km)', _display(r['ride_distance_km'])),
                if (_hasSupportFields(r, ['driver_latitude', 'driver_longitude']))
                  _kv(
                    context,
                    theme,
                    'Driver last location',
                    '${_display(r['driver_latitude'])} , ${_display(r['driver_longitude'])}',
                    copyValue:
                        '${_display(r['driver_latitude'])},${_display(r['driver_longitude'])}',
                  ),
                _kv(context, theme, 'Vehicle plate', _display(r['vehicle_plate'])),
                _kv(context, theme, 'Registration', _display(r['registration_number'])),
              ],
            ),
            _sectionCard(
              context,
              theme,
              'Fare & payment',
              Icons.payments_outlined,
              [
                _kv(context, theme, 'Estimated fare', _rupee(r['estimated_fare'])),
                _kv(context, theme, 'Final fare', _rupee(r['final_fare'])),
                _kv(context, theme, 'Extra fare', _rupee(r['extra_fare'])),
                _kv(context, theme, 'Discount', _rupee(r['discount_amount'])),
                _kv(context, theme, 'Coins used', _display(r['coins_used'])),
                _kv(context, theme, 'Voucher discount (₹)', _display(r['voucher_discount_inr'])),
                _kv(context, theme, 'Payment method', _display(r['payment_method'])),
                _kv(context, theme, 'Payment ID', _display(r['payment_id'])),
              ],
            ),
            if (_hasSupportFields(r, [
              'otp',
              'otp_expires_at',
              'otp_verified_at',
              'otp_attempts',
            ]))
              _sectionCard(
                context,
                theme,
                'OTP & verification',
                Icons.pin_outlined,
                [
                  _kv(context, theme, 'OTP', _display(r['otp']),
                      copyValue: _display(r['otp']) != '—' ? _display(r['otp']) : null),
                  _kv(context, theme, 'OTP expires', _displayDate(r['otp_expires_at'])),
                  _kv(context, theme, 'OTP verified at', _displayDate(r['otp_verified_at'])),
                  _kv(context, theme, 'OTP attempts', _display(r['otp_attempts'])),
                ],
              ),
            _sectionCard(
              context,
              theme,
              'Timeline',
              Icons.schedule_rounded,
              [
                _kv(context, theme, 'Created', _displayDate(r['created_at'] ?? r['createdAt'])),
                _kv(context, theme, 'Updated', _displayDate(r['updated_at'])),
                _kv(context, theme, 'Request time', _displayDate(r['request_time'])),
                _kv(context, theme, 'Accepted', _displayDate(r['accepted_time'])),
                _kv(context, theme, 'Driver arrived', _displayDate(r['driver_arrived_time'])),
                _kv(context, theme, 'Ride start', _displayDate(r['ride_start_time'])),
                _kv(context, theme, 'Ride end', _displayDate(r['ride_end_time'])),
                _kv(context, theme, 'Est. duration (min)', _display(r['estimated_duration_minutes'])),
                _kv(context, theme, 'Actual duration (min)', _display(r['actual_duration_minutes'])),
                _kv(context, theme, 'Cancelled at', _displayDate(r['cancelled_at'])),
                _kv(context, theme, 'Cancelled by', _display(r['cancelled_by'])),
                _kv(context, theme, 'Cancellation reason', r['cancellation_reason']?.toString(),
                    multiline: true),
              ],
            ),
            if (_hasSupportFields(r, [
                  'total_drivers_notified',
                  'decline_count',
                ]) ||
                _fromAdminApi)
              _sectionCard(
                context,
                theme,
                'Matching & retries',
                Icons.groups_2_outlined,
                [
                  _kv(context, theme, 'Drivers notified', _display(r['total_drivers_notified'])),
                  _kv(context, theme, 'Decline count', _display(r['decline_count'])),
                  _kv(context, theme, 'Parent ride ID', _display(r['parent_ride_id'])),
                  _kv(context, theme, 'Retry attempt', _display(r['retry_attempt_no'])),
                  _kv(context, theme, 'Replaced by ride ID', _display(r['replaced_by_ride_id'])),
                ],
              ),
            if (_fromAdminApi)
              _sectionCard(
                context,
                theme,
                'Guest / booking',
                Icons.person_add_alt_1_outlined,
                [
                  _kv(context, theme, 'Contact person', _display(r['user_contact_person'])),
                  _kv(context, theme, 'Guest name', _display(r['guest_name'])),
                  _kv(context, theme, 'Guest phone', _display(r['guest_phone']),
                      copyValue:
                          _display(r['guest_phone']) != '—' ? _display(r['guest_phone']) : null),
                  _kv(context, theme, 'Guest instructions', r['guest_instructions']?.toString(),
                      multiline: true),
                ],
              ),
            if (_fromAdminApi)
              _sectionCard(
                context,
                theme,
                'Notes',
                Icons.notes_rounded,
                [
                  _kv(context, theme, 'Rider notes', r['user_notes']?.toString(), multiline: true),
                  _kv(context, theme, 'Driver notes', r['driver_notes']?.toString(), multiline: true),
                ],
              ),
            if (_fromAdminApi)
              _sectionCard(
                context,
                theme,
                'Refund',
                Icons.currency_exchange_rounded,
                [
                  _kv(context, theme, 'Refund status', _display(r['refund_status'])),
                  _kv(context, theme, 'Refund amount', _rupee(r['refund_amount'])),
                  _kv(context, theme, 'Refund date', _displayDate(r['refund_date'])),
                ],
              ),
            if (_profilesLoading &&
                (_partyUserId(r) != null || _partyDriverId(r) != null))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Loading user & driver profiles by ID…',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _nestedMapCard(
              context,
              theme,
              _userProfile != null
                  ? 'Rider Details'
                  : 'Rider',
              Icons.person_rounded,
              _riderPayloadForCard(r),
            ),
            _nestedMapCard(
              context,
              theme,
              _driverProfile != null
                  ? 'Driver Details'
                  : 'Driver',
              Icons.local_taxi_rounded,
              _driverPayloadForCard(r),
            ),
            _nestedMapCard(
                context, theme, 'Admin vehicle', Icons.directions_car_filled_outlined, r['adminVehicle']),
            _nestedMapCard(context, theme, 'Driver vehicle', Icons.car_rental_rounded, r['vehicle']),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Map<String, dynamic> r, FlutterFlowTheme theme) {
    final status = _display(r['ride_status']);
    final booking = _display(r['booking_mode']);
    final rideType = _display(r['ride_type']);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#RD${widget.rideId}',
                      style: GoogleFonts.interTight(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fromAdminApi
                          ? 'Full admin record'
                          : 'Ride ID: ${widget.rideId}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy ride ID',
                onPressed: () => _copy('Ride ID', widget.rideId?.toString()),
                icon: Icon(Icons.copy_rounded, color: Colors.white.withValues(alpha: 0.95)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(status, Colors.white),
              if (booking != '—') _chip(booking, Colors.white70),
              if (rideType != '—') _chip(rideType, Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          _personRow(
            theme,
            label: 'Rider',
            name: _riderDisplayName(r),
            phone: _riderPhone(r),
            avatarUrl: _riderPhotoUrl(r),
            light: true,
          ),
          const SizedBox(height: 8),
          _personRow(
            theme,
            label: 'Driver',
            name: _driverDisplayName(r),
            phone: _driverPhone(r),
            avatarUrl: _driverPhotoUrl(r),
            light: true,
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _personRow(
    FlutterFlowTheme theme, {
    required String label,
    required String name,
    String? phone,
    String? avatarUrl,
    bool light = false,
  }) {
    final fg = light ? Colors.white : theme.primaryText;
    final sub = light ? Colors.white.withValues(alpha: 0.85) : theme.secondaryText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avatarUrl != null && avatarUrl.isNotEmpty) ...[
          _headerAvatar(theme, avatarUrl, light: light),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600, color: sub, letterSpacing: 0.6)),
              Text(name,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
              if (phone != null)
                Text(phone, style: GoogleFonts.inter(fontSize: 12, color: sub)),
            ],
          ),
        ),
        if (phone != null)
          IconButton(
            onPressed: () => _dial(phone),
            icon: Icon(Icons.phone, size: 20, color: light ? Colors.white : theme.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
      ],
    );
  }

  Widget _headerAvatar(
    FlutterFlowTheme theme,
    String url, {
    required bool light,
  }) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 44,
          height: 44,
          color: light ? Colors.white24 : theme.alternate,
          child: Icon(Icons.person,
              size: 22, color: light ? Colors.white70 : theme.secondaryText),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 44,
          height: 44,
          color: light ? Colors.white24 : theme.alternate,
          child: Icon(Icons.person_off_outlined,
              size: 20, color: light ? Colors.white70 : theme.secondaryText),
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context,
    FlutterFlowTheme theme,
    String title,
    IconData icon,
    List<Widget> rows,
  ) {
    final visible = rows.where((w) => w != const SizedBox.shrink()).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.alternate.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: theme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(children: visible),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(
    BuildContext context,
    FlutterFlowTheme theme,
    String label,
    String? value, {
    bool multiline = false,
    String? copyValue,
  }) {
    final v = value ?? '—';
    if (v == '—' && copyValue == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
              maxLines: multiline ? 8 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (copyValue != null && copyValue.isNotEmpty)
            IconButton(
              tooltip: 'Copy',
              icon: Icon(Icons.copy, size: 18, color: theme.secondaryText),
              onPressed: () => _copy(label, copyValue),
            ),
        ],
      ),
    );
  }

  Widget _nestedMapCard(
    BuildContext context,
    FlutterFlowTheme theme,
    String title,
    IconData icon,
    dynamic raw,
  ) {
    final m = _coerceMap(raw);
    if (m == null || m.isEmpty) return const SizedBox.shrink();

    final rows = _detailRowsFromMap(context, theme, m);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.alternate.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: theme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(children: rows),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _detailRowsFromMap(
    BuildContext context,
    FlutterFlowTheme theme,
    Map<String, dynamic> map, {
    int depth = 0,
  }) {
    if (depth > 5) return [];

    final entries = map.entries.where((e) {
      if (_isHiddenKey(e.key)) return false;
      final v = e.value;
      if (v == null) return false;
      if (v is Map && (_coerceMap(v)?.isEmpty ?? true)) return false;
      if (v is List && v.isEmpty) return false;
      final s = v.toString().trim();
      return s.isNotEmpty && s != 'null';
    }).toList()
      ..sort((a, b) {
        final ai = _detailSortIndex(a.key);
        final bi = _detailSortIndex(b.key);
        if (ai != bi) return ai.compareTo(bi);
        return a.key.compareTo(b.key);
      });

    return entries
        .map((e) => _detailRowForKeyValue(context, theme, e.key, e.value,
            depth: depth))
        .toList();
  }

  /// Prefer id, names, then photos, then the rest.
  int _detailSortIndex(String key) {
    final k = key.toLowerCase();
    if (k == 'id') return 0;
    if (k.contains('first_name') || k == 'name' || k.contains('last_name')) {
      return 1;
    }
    if (k.contains('profile_image') ||
        k.contains('photo') ||
        k == 'avatar' ||
        k.contains('thumbnail')) {
      return 2;
    }
    if (k.contains('mobile') || k.contains('phone') || k.contains('email')) {
      return 3;
    }
    return 50;
  }

  Widget _detailRowForKeyValue(
    BuildContext context,
    FlutterFlowTheme theme,
    String key,
    dynamic value, {
    int depth = 0,
  }) {
    if (_isHiddenKey(key)) return const SizedBox.shrink();

    final label = _titleCaseKey(key);

    if (value is Map) {
      final child = _coerceMap(value);
      if (child == null || child.isEmpty) return const SizedBox.shrink();
      final inner = _detailRowsFromMap(context, theme, child, depth: depth + 1);
      if (inner.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 6),
            childrenPadding: const EdgeInsets.only(left: 8, right: 4, bottom: 8),
            title: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: theme.primaryText,
              ),
            ),
            children: inner,
          ),
        ),
      );
    }

    if (value is List) {
      final text = _formatListForAdmin(value);
      return _kv(context, theme, label, text, multiline: text.length > 60);
    }

    if (value is bool) {
      return _kv(context, theme, label, value ? 'Yes' : 'No');
    }

    final strVal = value.toString().trim();
    if (strVal.isEmpty || strVal == 'null') {
      return const SizedBox.shrink();
    }

    if (_shouldRenderAsImage(key, strVal)) {
      final url = _resolveImageUrl(strVal);
      if (url.isNotEmpty) {
        return _detailImageRow(context, theme, label, url);
      }
    }

    final formatted = _formatScalarForKey(key, value);
    final copy = _copyValueForKey(key, formatted);
    return _kv(
      context,
      theme,
      label,
      formatted,
      multiline: formatted.length > 48,
      copyValue: copy,
    );
  }

  String? _copyValueForKey(String key, String formatted) {
    if (formatted == '—') return null;
    final kl = key.toLowerCase();
    if (kl.contains('phone') ||
        kl.contains('mobile') ||
        kl.contains('email') ||
        kl == 'id') {
      return formatted;
    }
    return null;
  }

  String _formatScalarForKey(String key, dynamic value) {
    final kl = key.toLowerCase();
    if (_looksLikeTimestampKey(kl)) {
      return _displayDate(value);
    }
    if (value is num && (kl == 'id' || kl.endsWith('_id'))) {
      return value.toString();
    }
    if (_looksLikeMoneyKey(kl) && _isNumericLike(value)) {
      return _rupee(value);
    }
    return _display(value);
  }

  bool _isNumericLike(dynamic v) {
    if (v is num) return true;
    if (v is String) return double.tryParse(v.trim()) != null;
    return false;
  }

  bool _looksLikeTimestampKey(String kl) {
    return kl.contains('_at') ||
        kl.contains('_time') ||
        kl == 'last_login' ||
        kl == 'created_at' ||
        kl == 'updated_at' ||
        kl == 'date';
  }

  bool _looksLikeMoneyKey(String kl) {
    if (kl.endsWith('_id')) return false;
    if (kl.contains('fare') ||
        kl.endsWith('_inr') ||
        kl.contains('voucher_discount')) {
      return true;
    }
    if ((kl.contains('amount') || kl.contains('price')) &&
        !kl.contains('attempt')) {
      return true;
    }
    if (kl.contains('fee') && !kl.contains('feedback')) return true;
    if (kl.contains('balance') && !kl.contains('id')) return true;
    if (kl.contains('discount') &&
        (kl.contains('amount') || kl.contains('inr'))) {
      return true;
    }
    if (kl.contains('refund') && kl.contains('amount')) return true;
    if (kl.contains('coins')) return true;
    return false;
  }

  bool _isImagePresentationKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('profile_image') ||
        k.contains('vehicle_image') ||
        k.contains('document_image')) {
      return true;
    }
    if (k == 'avatar' || k.contains('photo') || k.contains('thumbnail')) {
      return true;
    }
    if (k.endsWith('_image') || k.endsWith('_url') && k.contains('image')) {
      return true;
    }
    return false;
  }

  bool _stringLooksLikeImageFile(String s) {
    final lower = s.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)(\?|#|$)',
              caseSensitive: false)
          .hasMatch(lower);
    }
    return lower.contains('upload') &&
        RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)', caseSensitive: false)
            .hasMatch(lower);
  }

  bool _shouldRenderAsImage(String key, String strVal) {
    final resolved = _resolveImageUrl(strVal);
    if (resolved.isEmpty) return false;
    if (_isImagePresentationKey(key)) return true;
    return _stringLooksLikeImageFile(strVal);
  }

  String _formatListForAdmin(List list) {
    if (list.isEmpty) return '—';
    if (list.every((e) => e is! Map && e is! List)) {
      return list.map((e) => e.toString()).join(', ');
    }
    return '${list.length} items';
  }

  Widget _detailImageRow(
    BuildContext context,
    FlutterFlowTheme theme,
    String label,
    String imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: theme.alternate.withValues(alpha: 0.35),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 132,
                      height: 132,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => SizedBox(
                        width: 132,
                        height: 132,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => SizedBox(
                        width: 132,
                        height: 132,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic>? _coerceMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

/// Builds a usable image URL from API paths such as `uploads/profiles/...`.
String _resolveImageUrl(String? raw) {
  if (raw == null || raw.isEmpty || raw == 'null') return '';
  final t = raw.trim();
  if (t.startsWith('http://') || t.startsWith('https://')) return t;
  return '${ApiConfig.baseUrl}/${t.replaceFirst(RegExp(r'^/'), '')}';
}

String _display(dynamic v) {
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty || s == 'null' ? '—' : s;
}

String _displayDate(dynamic v) {
  if (v == null) return '—';
  try {
    final dt = DateTime.tryParse(v.toString());
    if (dt == null) return _display(v);
    return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
  } catch (_) {
    return v.toString();
  }
}

String _rupee(dynamic v) {
  if (v == null) return '—';
  final s = v.toString().trim();
  if (s.isEmpty || s == 'null') return '—';
  return '₹$s';
}

String _titleCaseKey(String key) {
  return key
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
