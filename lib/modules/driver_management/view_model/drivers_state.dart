import 'package:equatable/equatable.dart';

import '/core/utils/view_state.dart';
import '/modules/driver_management/model/drivers_model.dart';

class DriversState extends Equatable with LoadStateMixin {
  const DriversState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.drivers = const [],
    this.query = '',
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<DriverListItem> drivers;
  final String query;

  List<DriverListItem> get filtered {
    if (query.isEmpty) return drivers;
    final q = query.toLowerCase();
    return drivers
        .where((d) =>
            d.displayName.toLowerCase().contains(q) ||
            d.phone.contains(q))
        .toList();
  }

  DriversState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<DriverListItem>? drivers,
    String? query,
  }) =>
      DriversState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        drivers: drivers ?? this.drivers,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [status, errorMessage, drivers, query];
}
