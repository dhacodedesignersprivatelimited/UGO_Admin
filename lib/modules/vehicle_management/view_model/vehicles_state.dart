import 'package:equatable/equatable.dart';
import '/core/utils/view_state.dart';
import '/modules/vehicle_management/model/vehicles_model.dart';

class VehiclesState extends Equatable with LoadStateMixin {
  const VehiclesState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.vehicles = const [],
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<VehicleTypeRef> vehicles;

  VehiclesState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<VehicleTypeRef>? vehicles,
  }) =>
      VehiclesState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        vehicles: vehicles ?? this.vehicles,
      );

  @override
  List<Object?> get props => [status, errorMessage, vehicles];
}
