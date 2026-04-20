import 'package:equatable/equatable.dart';
import '/core/utils/view_state.dart';

class ZonesState extends Equatable with LoadStateMixin {
  const ZonesState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.zones = const [],
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<dynamic> zones;

  ZonesState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<dynamic>? zones,
  }) =>
      ZonesState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        zones: zones ?? this.zones,
      );

  @override
  List<Object?> get props => [status, errorMessage, zones];
}
