import 'package:equatable/equatable.dart';

import '/shared/models/domain_enums.dart';

class GeoPoint extends Equatable {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

class RideSummary extends Equatable {
  const RideSummary({
    required this.id,
    required this.riderName,
    required this.driverName,
    required this.status,
    required this.pickupLabel,
    required this.dropLabel,
    required this.fare,
    required this.requestedAt,
    this.driverId,
    this.riderId,
  });

  final String id;
  final String riderName;
  final String driverName;
  final RideLifecycleStatus status;
  final String pickupLabel;
  final String dropLabel;
  final double fare;
  final DateTime requestedAt;
  final String? driverId;
  final String? riderId;

  @override
  List<Object?> get props => [
        id,
        riderName,
        driverName,
        status,
        pickupLabel,
        dropLabel,
        fare,
        requestedAt,
        driverId,
        riderId,
      ];
}

class RideDetail extends Equatable {
  const RideDetail({
    required this.summary,
    required this.pickup,
    required this.drop,
    required this.routePolyline,
    this.commission,
    this.surgeMultiplier,
  });

  final RideSummary summary;
  final GeoPoint pickup;
  final GeoPoint drop;
  final String routePolyline;
  final double? commission;
  final double? surgeMultiplier;

  @override
  List<Object?> get props =>
      [summary, pickup, drop, routePolyline, commission, surgeMultiplier];
}
