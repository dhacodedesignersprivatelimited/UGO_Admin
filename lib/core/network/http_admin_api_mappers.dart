import '/config/theme/flutter_flow_util.dart';
import '/modules/ride_management/view/ride_row_data.dart';

import '/shared/models/domain_enums.dart';
import '/modules/driver_management/model/drivers_model.dart';
import '/modules/finance_management/model/finance_model.dart';
import '/modules/promo_codes/model/promo_codes_model.dart';
import '/modules/user_management/model/users_model.dart';
import '/modules/ride_management/model/rides_model.dart';
import '/modules/vehicle_management/model/vehicles_model.dart';

int? _int(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.round();
  return int.tryParse(v.toString().trim());
}

double? _double(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().trim());
}

String _str(dynamic v) => v?.toString().trim() ?? '';

KycReviewStatus mapKyc(String? raw) {
  final s = (raw ?? '').toLowerCase();
  if (s.contains('approve') || s == 'verified') return KycReviewStatus.approved;
  if (s.contains('reject') || s.contains('declin')) return KycReviewStatus.rejected;
  return KycReviewStatus.pending;
}

DriverPresenceStatus mapDriverPresence({
  required bool isOnline,
  required bool isActive,
  String? accountStatus,
}) {
  final ac = (accountStatus ?? '').toLowerCase();
  if (ac.contains('block') || !isActive) return DriverPresenceStatus.blocked;
  if (isOnline) return DriverPresenceStatus.online;
  return DriverPresenceStatus.offline;
}

DriverListItem mapDriverRow(dynamic d, int index) {
  final first = _str(getJsonField(d, r'''$.first_name'''));
  final last = _str(getJsonField(d, r'''$.last_name'''));
  var name = '$first $last'.trim();
  if (name.isEmpty) name = _str(getJsonField(d, r'''$.name'''));
  if (name.isEmpty) name = 'Driver ${index + 1}';

  final phone = _str(getJsonField(d, r'''$.mobile_number'''));
  final phoneAlt = _str(getJsonField(d, r'''$.phone'''));
  final phoneFinal = phone.isNotEmpty ? phone : phoneAlt;
  final id = _int(getJsonField(d, r'''$.id''')) ?? index;
  final isOnline = _bool(getJsonField(d, r'''$.is_online'''));
  final isActive = _bool(getJsonField(d, r'''$.is_active''') ?? getJsonField(d, r'''$.active_driver'''));
  final acct = _str(getJsonField(d, r'''$.account_status'''));
  final kycA = _str(getJsonField(d, r'''$.kyc_status'''));
  final kycB = _str(getJsonField(d, r'''$.verification_status'''));
  final kycRaw = kycA.isNotEmpty ? kycA : kycB;

  String vehicle = '';
  for (final path in [
    r'''$.adminVehicle.vehicle_name''',
    r'''$.vehicle_type''',
    r'''$.vehicle_number''',
  ]) {
    final v = _str(getJsonField(d, path));
    if (v.isNotEmpty && v != 'null') {
      vehicle = v;
      break;
    }
  }
  if (vehicle.isEmpty) vehicle = 'Not assigned';

  final rating = _double(getJsonField(d, r'''$.rating''')) ?? 0;

  return DriverListItem(
    id: id.toString(),
    displayName: name,
    phone: phoneFinal.isNotEmpty ? phoneFinal : '—',
    presence: mapDriverPresence(
      isOnline: isOnline,
      isActive: isActive,
      accountStatus: acct,
    ),
    kycStatus: mapKyc(kycRaw.isEmpty ? null : kycRaw),
    vehicleLabel: vehicle,
    rating: rating,
  );
}

bool _bool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase() ?? '';
  return s == 'true' || s == '1';
}

RiderListItem mapUserRow(dynamic u, int index) {
  final id = _int(getJsonField(u, r'''$.id''') ?? getJsonField(u, r'''$.user_id''')) ?? index;
  final first = _str(getJsonField(u, r'''$.first_name'''));
  final last = _str(getJsonField(u, r'''$.last_name'''));
  var name = '$first $last'.trim();
  if (name.isEmpty) name = _str(getJsonField(u, r'''$.name'''));
  if (name.isEmpty) name = 'User ${index + 1}';
  final phone = _str(getJsonField(u, r'''$.mobile_number'''));
  final phoneAlt = _str(getJsonField(u, r'''$.phone'''));
  final phoneFinal = phone.isNotEmpty ? phone : phoneAlt;
  final blocked = _bool(getJsonField(u, r'''$.is_blocked''')) ||
      _bool(getJsonField(u, r'''$.blocked'''));
  final wallet = _double(getJsonField(u, r'''$.wallet_balance''')) ??
      _double(getJsonField(u, r'''$.walletBalance''')) ??
      0.0;
  return RiderListItem(
    id: id.toString(),
    displayName: name,
    phone: phoneFinal.isNotEmpty ? phoneFinal : '—',
    isBlocked: blocked,
    walletBalance: wallet,
  );
}

RideLifecycleStatus mapRideStatus(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('cancel')) {
    if (s.contains('admin')) return RideLifecycleStatus.cancelledByAdmin;
    if (s.contains('driver')) return RideLifecycleStatus.cancelledByDriver;
    return RideLifecycleStatus.cancelledByRider;
  }
  if (s.contains('complete')) return RideLifecycleStatus.completed;
  if (s.contains('assign') || s == 'accepted' || s.contains('driver_assigned')) {
    return RideLifecycleStatus.assigned;
  }
  if (s.contains('arriv')) return RideLifecycleStatus.arrived;
  if (s.contains('progress') || s.contains('started') || s.contains('picked')) {
    return RideLifecycleStatus.inProgress;
  }
  if (s.contains('search') || s.contains('request') || s == 'pending') {
    return RideLifecycleStatus.requested;
  }
  return RideLifecycleStatus.requested;
}

RideSummary mapRideRow(dynamic r) {
  final row = RideRowData.tryParse(r);
  final m = row != null ? row.m : (r is Map ? Map<String, dynamic>.from(r) : <String, dynamic>{});
  final idVal = m['id'];
  final id = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '') ?? 0;
  final statusRaw = m['ride_status']?.toString() ?? '';
  final fare = _double(m['final_fare']) ?? _double(m['estimated_fare']) ?? _double(m['fare']) ?? 0;
  DateTime requestedAt = DateTime.now();
  for (final key in ['created_at', 'ride_date', 'updated_at']) {
    final raw = m[key];
    if (raw == null) continue;
    try {
      requestedAt = DateTime.parse(raw.toString());
      break;
    } catch (_) {}
  }
  final pickup = m['pickup_address']?.toString() ?? m['from_address']?.toString() ?? 'Pickup';
  final drop = m['drop_address']?.toString() ?? m['to_address']?.toString() ?? 'Drop';
  final riderName = row?.riderName ?? 'Rider';
  final driverName = row?.driverName ?? '—';
  final driverId = row?.linkedDriverId;
  final riderId = row?.riderUserId;
  return RideSummary(
    id: id.toString(),
    riderName: riderName,
    driverName: driverName,
    status: mapRideStatus(statusRaw),
    pickupLabel: pickup,
    dropLabel: drop,
    fare: fare,
    requestedAt: requestedAt,
    driverId: driverId?.toString(),
    riderId: riderId?.toString(),
  );
}

WithdrawalRequest mapWithdrawalRow(Map<String, dynamic> p) {
  final payoutId = _int(p['payout_id']) ?? _int(p['id']) ?? 0;
  final driverId = _int(p['driver_id']) ?? 0;
  final driver = p['driver'] is Map ? Map<String, dynamic>.from(p['driver'] as Map) : null;
  final name = _str(p['driver_name']).isNotEmpty
      ? _str(p['driver_name'])
      : _str(driver?['name']);
  final amount = _double(p['amount_raw']) ?? _double(p['amount']) ?? 0;
  final statusStr = _str(p['status']).toLowerCase();
  WithdrawalStatus st = WithdrawalStatus.pending;
  if (statusStr.contains('paid') || statusStr.contains('complete')) {
    st = WithdrawalStatus.paid;
  } else if (statusStr.contains('reject')) {
    st = WithdrawalStatus.rejected;
  } else if (statusStr.contains('approv')) {
    st = WithdrawalStatus.approved;
  }
  DateTime at = DateTime.now();
  final req = p['request_date'] ?? p['requested_date'] ?? p['created_at'];
  if (req != null) {
    try {
      at = DateTime.parse(req.toString());
    } catch (_) {}
  }
  return WithdrawalRequest(
    id: payoutId.toString(),
    driverId: driverId.toString(),
    driverName: name.isNotEmpty ? name : 'Driver #$driverId',
    amount: amount,
    status: st,
    requestedAt: at,
    bankMasked: _str(p['upi_or_bank']),
  );
}

ComplaintStatus mapComplaintStatus(String? raw) {
  final s = (raw ?? '').toLowerCase();
  if (s.contains('resolv')) return ComplaintStatus.resolved;
  if (s.contains('escalat')) return ComplaintStatus.escalated;
  if (s.contains('review') || s.contains('progress')) return ComplaintStatus.inReview;
  return ComplaintStatus.open;
}

RiderComplaint mapComplaintRow(Map<String, dynamic> c) {
  final id = _int(c['id'] ?? c['complaint_id']) ?? 0;
  final riderId = _int(c['user_id'] ?? c['rider_id']) ?? 0;
  final rideId = _int(c['ride_id']);
  DateTime at = DateTime.now();
  final raw = c['created_at'] ?? c['createdAt'];
  if (raw != null) {
    try {
      at = DateTime.parse(raw.toString());
    } catch (_) {}
  }
  return RiderComplaint(
    id: id.toString(),
    riderId: riderId.toString(),
    subject: _str(c['subject'] ?? c['title'] ?? 'Complaint'),
    body: _str(c['description'] ?? c['message'] ?? c['details'] ?? ''),
    status: mapComplaintStatus(c['status']?.toString()),
    createdAt: at,
    rideId: rideId?.toString(),
  );
}

PromoCode mapPromoRow(Map<String, dynamic> p) {
  final id = _int(p['id'] ?? p['promo_id']) ?? 0;
  final typeStr = _str(p['discount_type']).toLowerCase();
  final discountType =
      typeStr.contains('fix') ? PromoDiscountType.fixedAmount : PromoDiscountType.percentage;
  final maxRed = _int(p['usage_limit'] ?? p['max_redemptions']) ?? 1;
  final used = _int(p['usage_count'] ?? p['redemptions_used']) ?? 0;
  DateTime start = DateTime.now().subtract(const Duration(days: 1));
  DateTime end = DateTime.now().add(const Duration(days: 30));
  for (final k in ['starts_at', 'start_date', 'created_at']) {
    final v = p[k];
    if (v != null) {
      try {
        start = DateTime.parse(v.toString());
        break;
      } catch (_) {}
    }
  }
  for (final k in ['expiry_date', 'ends_at', 'end_date']) {
    final v = p[k];
    if (v != null) {
      try {
        end = DateTime.parse(v.toString());
        break;
      } catch (_) {}
    }
  }
  return PromoCode(
    id: id.toString(),
    code: _str(p['code_name'] ?? p['code'] ?? 'PROMO'),
    discountType: discountType,
    discountValue: _double(p['discount_value']) ?? 0,
    maxRedemptions: maxRed,
    redemptionsUsed: used,
    startsAt: start,
    endsAt: end,
    isActive: !_bool(p['is_deactivated'] ?? p['inactive']),
  );
}

VehicleTypeRef mapVehicleTypeRow(Map<String, dynamic> m) {
  final id = _int(m['id']) ?? 0;
  return VehicleTypeRef(
    id: id.toString(),
    name: _str(m['name'] ?? m['vehicle_type'] ?? 'Type'),
    imageUrl: _str(m['image'] ?? m['image_url']).isEmpty ? null : _str(m['image'] ?? m['image_url']),
  );
}
