import '/backend/api_requests/api_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Normalized ride fields for list/table UIs (matches `GetRidesCall` payloads).
///
/// When [userDetail] / [driverDetail] are set (from [GetUserByIdCall] /
/// [GetDriverByIdCall]), those override names, phones, and avatars.
class RideRowData {
  RideRowData._(
    this.m, {
    Map<String, dynamic>? userDetail,
    Map<String, dynamic>? driverDetail,
  })  : _userDetail = userDetail,
        _driverDetail = driverDetail;

  final Map<String, dynamic> m;
  final Map<String, dynamic>? _userDetail;
  final Map<String, dynamic>? _driverDetail;

  static RideRowData? tryParse(
    dynamic r, {
    Map<String, dynamic>? userDetail,
    Map<String, dynamic>? driverDetail,
  }) {
    if (r is Map<String, dynamic>) {
      return RideRowData._(r,
          userDetail: userDetail, driverDetail: driverDetail);
    }
    if (r is Map) {
      return RideRowData._(Map<String, dynamic>.from(r),
          userDetail: userDetail, driverDetail: driverDetail);
    }
    return null;
  }

  static String _imageUrl(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return '';
    if (raw.startsWith('http')) return raw;
    return '${ApiConfig.baseUrl}/${raw.replaceFirst(RegExp(r'^/'), '')}';
  }

  static int? _parseId(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  /// User id for [GetUserByIdCall] / party enrichment (supports common API shapes).
  static int? parseRiderUserId(Map<String, dynamic> m) {
    for (final k in [
      'rider_id',
      'user_id',
      'passenger_id',
      'customer_id',
      'rider_user_id',
      'usr_id',
      'userid',
    ]) {
      final id = _parseId(m[k]);
      if (id != null) return id;
    }
    for (final nestedKey in ['user', 'rider', 'passenger', 'customer']) {
      final u = m[nestedKey];
      if (u is Map) {
        final um = Map<String, dynamic>.from(u);
        for (final k in ['id', 'user_id']) {
          final id = _parseId(um[k]);
          if (id != null) return id;
        }
      }
    }
    return null;
  }

  /// Driver id for [GetDriverByIdCall] / party enrichment.
  static int? parseDriverId(Map<String, dynamic> m) {
    for (final k in ['driver_id', 'assigned_driver_id']) {
      final id = _parseId(m[k]);
      if (id != null) return id;
    }
    final d = m['driver'];
    if (d is Map) {
      final dm = Map<String, dynamic>.from(d);
      for (final k in ['id', 'driver_id']) {
        final id = _parseId(dm[k]);
        if (id != null) return id;
      }
    }
    return null;
  }

  /// Rider / passenger user id for API lookup.
  int? get riderUserId => parseRiderUserId(m);

  int? get linkedDriverId => parseDriverId(m);

  String? _riderImageRaw() {
    final u = _userDetail;
    if (u != null) {
      final p = u['profile_image']?.toString();
      if (p != null && p.isNotEmpty && p != 'null') return p;
    }
    for (final k in [
      'rider_profile_image',
      'user_profile_image',
      'passenger_image',
      'profile_image',
      'rider_image',
      'customer_image',
    ]) {
      final v = m[k]?.toString();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    final user = m['user'] ?? m['rider'] ?? m['passenger'];
    if (user is Map && user['profile_image'] != null) {
      return user['profile_image'].toString();
    }
    return null;
  }

  String? _driverImageRaw() {
    final d = _driverDetail;
    if (d != null) {
      final p = d['profile_image']?.toString();
      if (p != null && p.isNotEmpty && p != 'null') return p;
    }
    for (final k in ['driver_profile_image', 'driver_image']) {
      final v = m[k]?.toString();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    final dm = m['driver'];
    if (dm is Map && dm['profile_image'] != null) {
      return dm['profile_image'].toString();
    }
    return null;
  }

  String get riderImageUrl => _imageUrl(_riderImageRaw());
  String get driverImageUrl => _imageUrl(_driverImageRaw());

  String get riderName {
    final u = _userDetail;
    if (u != null) {
      final nm = u['name']?.toString().trim();
      if (nm != null && nm.isNotEmpty) return nm;
      final fn = u['first_name']?.toString() ?? '';
      final ln = u['last_name']?.toString() ?? '';
      final c = '$fn $ln'.trim();
      if (c.isNotEmpty) return c;
    }
    final name = m['rider_name'] ??
        m['user_name'] ??
        m['passenger_name'] ??
        m['customer_name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }
    final first = m['rider_first_name'] ?? m['passenger_first_name'];
    final last = m['rider_last_name'] ?? m['passenger_last_name'];
    final combined = '${first ?? ''} ${last ?? ''}'.trim();
    if (combined.isNotEmpty) return combined;
    final user = m['user'] ?? m['rider'];
    if (user is Map) {
      final fn = user['first_name'];
      final ln = user['last_name'];
      final uu = '${fn ?? ''} ${ln ?? ''}'.trim();
      if (uu.isNotEmpty) return uu;
    }
    final id = m['user_id'] ?? m['rider_id'];
    if (id != null) return 'User #$id';
    return 'User';
  }

  String get riderPhone {
    final u = _userDetail;
    if (u != null) {
      for (final k in ['mobile_number', 'phone']) {
        final v = u[k];
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty && s != 'null') return s;
        }
      }
    }
    for (final k in [
      'rider_phone',
      'passenger_phone',
      'user_phone',
      'customer_phone',
      'mobile_number',
      'phone',
    ]) {
      final v = m[k];
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty && s != 'null') return s;
      }
    }
    final user = m['user'] ?? m['rider'];
    if (user is Map) {
      for (final k in ['mobile_number', 'phone']) {
        final v = user[k];
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty && s != 'null') return s;
        }
      }
    }
    return '';
  }

  String get driverName {
    final d = _driverDetail;
    if (d != null) {
      final nm = d['name']?.toString().trim();
      if (nm != null && nm.isNotEmpty) return nm;
      final fn = d['first_name']?.toString() ?? '';
      final ln = d['last_name']?.toString() ?? '';
      final c = '$fn $ln'.trim();
      if (c.isNotEmpty) return c;
    }
    final name = m['driver_name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }
    final first = m['driver_first_name'];
    final last = m['driver_last_name'];
    final combined = '${first ?? ''} ${last ?? ''}'.trim();
    if (combined.isNotEmpty) return combined;
    final dm = m['driver'];
    if (dm is Map) {
      final fn = dm['first_name'];
      final ln = dm['last_name'];
      final n = '${fn ?? ''} ${ln ?? ''}'.trim();
      if (n.isNotEmpty) return n;
    }
    final id = m['driver_id'];
    if (id != null) return 'Driver #$id';
    return '—';
  }

  String get driverPhone {
    final d = _driverDetail;
    if (d != null) {
      for (final k in ['mobile_number', 'phone']) {
        final v = d[k];
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty && s != 'null') return s;
        }
      }
    }
    for (final k in [
      'driver_phone',
      'driver_mobile',
      'driver_mobile_number',
    ]) {
      final v = m[k];
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty && s != 'null') return s;
      }
    }
    final dm = m['driver'];
    if (dm is Map) {
      for (final k in ['mobile_number', 'phone']) {
        final v = dm[k];
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty && s != 'null') return s;
        }
      }
    }
    return '';
  }

  String get rideIdLabel {
    final idVal = m['id'];
    final id = idVal is int
        ? idVal
        : int.tryParse(idVal?.toString() ?? '');
    if (id == null) return '—';
    return '#RD$id';
  }

  int? get rideId {
    final idVal = m['id'];
    if (idVal is int) return idVal;
    return int.tryParse(idVal?.toString() ?? '');
  }

  String get fare {
    final f = m['final_fare'] ?? m['estimated_fare'] ?? m['fare'];
    if (f == null) return '—';
    return '₹$f';
  }

  String get statusRaw => (m['ride_status'] ?? '').toString();

  String get humanStatus {
    final s = statusRaw.toLowerCase();
    if (s.contains('cancel')) return 'Cancelled';
    if (s == 'completed') return 'Completed';
    if (s.isEmpty) return '—';
    return 'Ongoing';
  }

  /// Who cancelled (for badges). Best-effort across common API field names.
  String get cancelSourceLabel {
    if (humanStatus != 'Cancelled') return 'Cancelled';
    for (final k in [
      'cancelled_by',
      'cancellation_by',
      'canceled_by',
      'cancel_by',
      'cancelled_by_type',
      'cancelled_by_role',
      'cancelled_by_user_type',
    ]) {
      final v = m[k]?.toString().toLowerCase() ?? '';
      if (v.contains('driver')) return 'Driver Cancelled';
      if (v.contains('user') ||
          v.contains('rider') ||
          v.contains('passenger') ||
          v.contains('customer')) {
        return 'User Cancelled';
      }
      if (v.contains('admin') || v.contains('system')) return 'System Cancelled';
    }
    final reason = (m['cancellation_reason'] ??
            m['cancel_reason'] ??
            m['cancellation_message'])
        ?.toString()
        .toLowerCase() ??
        '';
    if (reason.contains('driver')) return 'Driver Cancelled';
    if (reason.contains('user') ||
        reason.contains('rider') ||
        reason.contains('passenger')) {
      return 'User Cancelled';
    }
    return 'Cancelled';
  }

  Color statusColor(FlutterFlowTheme theme) {
    switch (humanStatus) {
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return theme.error;
      case 'Ongoing':
        return const Color(0xFFFF9800);
      default:
        return theme.secondaryText;
    }
  }

  String get time24 {
    for (final key in [
      'created_at',
      'ride_date',
      'updated_at',
      'scheduled_at',
    ]) {
      final raw = m[key];
      if (raw == null) continue;
      try {
        final dt = DateTime.parse(raw.toString()).toLocal();
        return DateFormat('HH:mm').format(dt);
      } catch (_) {}
    }
    return '—';
  }

  /// Parsed ride time for sorting (newest first).
  DateTime? get requestedAt {
    for (final key in [
      'created_at',
      'ride_date',
      'updated_at',
      'scheduled_at',
    ]) {
      final raw = m[key];
      if (raw == null) continue;
      try {
        return DateTime.parse(raw.toString()).toLocal();
      } catch (_) {}
    }
    return null;
  }

  /// Second line under ride id (e.g. `10 Apr, 10:25 PM`).
  String get rideSubtitle {
    final dt = requestedAt;
    if (dt == null) return '';
    return DateFormat('d MMM, h:mm a').format(dt);
  }

  /// Cash / UPI / Card / — (cancelled or unknown).
  String get paymentLabel {
    if (humanStatus == 'Cancelled') return '—';
    final p = m['payment_method'] ??
        m['payment_type'] ??
        m['payment_mode'] ??
        m['mode'];
    if (p == null) return '—';
    final s = p.toString().trim();
    if (s.isEmpty || s == 'null') return '—';
    final lower = s.toLowerCase();
    if (lower.contains('cash')) return 'Cash';
    if (lower.contains('upi')) return 'UPI';
    if (lower.contains('card') || lower.contains('online')) return 'Card';
    return s;
  }

  /// e.g. `18.5 km, 30 min` when backend sends distance/duration fields.
  String get distanceDurationLine {
    final kmRaw = m['total_distance'] ??
        m['trip_distance'] ??
        m['distance_km'] ??
        m['distance'];
    final minRaw = m['trip_duration'] ??
        m['duration_minutes'] ??
        m['duration'] ??
        m['time_taken'];

    String kmPart = '';
    if (kmRaw != null) {
      final k = double.tryParse(kmRaw.toString());
      if (k != null) {
        kmPart = k == k.roundToDouble()
            ? '${k.round()} km'
            : '${k.toStringAsFixed(1)} km';
      } else {
        final t = kmRaw.toString().trim();
        if (t.isNotEmpty) kmPart = t.contains('km') ? t : '$t km';
      }
    }

    String minPart = '';
    if (minRaw != null) {
      final asInt = int.tryParse(minRaw.toString());
      if (asInt != null) {
        minPart = '$asInt min';
      } else {
        final d = double.tryParse(minRaw.toString());
        if (d != null) {
          minPart = '${d.round()} min';
        }
      }
    }

    if (kmPart.isEmpty && minPart.isEmpty) return '—';
    if (kmPart.isEmpty) return minPart;
    if (minPart.isEmpty) return kmPart;
    return '$kmPart, $minPart';
  }

  String get pickup => m['pickup_location_address']?.toString() ?? '—';
  String get drop => m['drop_location_address']?.toString() ?? '—';
}
