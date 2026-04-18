import 'package:equatable/equatable.dart';

class VehicleTypeRef extends Equatable {
  const VehicleTypeRef({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];
}

class VehicleSubtypeRef extends Equatable {
  const VehicleSubtypeRef({
    required this.id,
    required this.label,
    required this.vehicleTypeId,
  });

  final String id;
  final String label;
  final String vehicleTypeId;

  @override
  List<Object?> get props => [id, label, vehicleTypeId];
}

class DriverVehicle extends Equatable {
  const DriverVehicle({
    required this.id,
    required this.registrationNumber,
    required this.modelName,
    required this.color,
    required this.type,
    required this.subtype,
    this.isPrimary = true,
  });

  final String id;
  final String registrationNumber;
  final String modelName;
  final String color;
  final VehicleTypeRef type;
  final VehicleSubtypeRef subtype;
  final bool isPrimary;

  @override
  List<Object?> get props =>
      [id, registrationNumber, modelName, color, type, subtype, isPrimary];
}
