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

  /// Rider / passenger user id for API lookup.
  int? get riderUserId {
    final v = m['rider_id'] ?? m['user_id'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  int? get linkedDriverId {
    final v = m['driver_id'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

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

  String get pickup => m['pickup_location_address']?.toString() ?? '—';
  String get drop => m['drop_location_address']?.toString() ?? '—';
}
