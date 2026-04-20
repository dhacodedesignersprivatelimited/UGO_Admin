import 'package:equatable/equatable.dart';

class FareSettings extends Equatable {
  const FareSettings({
    required this.baseFare,
    required this.perKm,
    required this.perMinute,
    required this.minimumFare,
    required this.platformCommissionPercent,
    required this.taxPercent,
  });

  final double baseFare;
  final double perKm;
  final double perMinute;
  final double minimumFare;
  final double platformCommissionPercent;
  final double taxPercent;

  @override
  List<Object?> get props => [
        baseFare,
        perKm,
        perMinute,
        minimumFare,
        platformCommissionPercent,
        taxPercent,
      ];
}

class SurgeBand extends Equatable {
  const SurgeBand({
    required this.id,
    required this.label,
    required this.multiplier,
    required this.active,
  });

  final String id;
  final String label;
  final double multiplier;
  final bool active;

  @override
  List<Object?> get props => [id, label, multiplier, active];
}

class GlobalSettingsSnapshot extends Equatable {
  const GlobalSettingsSnapshot({
    required this.fare,
    required this.surgeBands,
    required this.updatedAt,
  });

  final FareSettings fare;
  final List<SurgeBand> surgeBands;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [fare, surgeBands, updatedAt];
}
