class RideModel {
  final String id;
  /// Shown in first line of Ride ID column (e.g. `#RD12580`).
  final String displayId;
  /// Second line under ride id (date/time); may be empty.
  final String dateSubtitle;
  final String userName;
  final String userPhone;
  final String driverName;
  final String driverPhone;
  final String pickup;
  final String drop;
  final String status;
  final String fare;
  final String paymentMethod;
  final String distanceDuration;
  /// Resolved profile image URLs (from ride payload or [GetUserByIdCall]/[GetDriverByIdCall]).
  final String riderAvatarUrl;
  final String driverAvatarUrl;

  RideModel({
    required this.id,
    required this.displayId,
    this.dateSubtitle = '',
    required this.userName,
    this.userPhone = '',
    required this.driverName,
    this.driverPhone = '',
    required this.pickup,
    required this.drop,
    required this.status,
    required this.fare,
    this.paymentMethod = '—',
    this.distanceDuration = '—',
    this.riderAvatarUrl = '',
    this.driverAvatarUrl = '',
  });
}