import 'package:equatable/equatable.dart';

import '/core/utils/view_state.dart';
import '/modules/ride_management/model/rides_model.dart';

class RidesState extends Equatable with LoadStateMixin {
  const RidesState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.rides = const [],
    this.query = '',
    this.statusFilter,
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<RideSummary> rides;
  final String query;
  final String? statusFilter;

  List<RideSummary> get filtered {
    var result = rides;
    if (statusFilter != null) {
      result = result
          .where((r) =>
              r.status.name.toLowerCase() == statusFilter!.toLowerCase())
          .toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((r) =>
              r.id.toLowerCase().contains(q) ||
              r.pickupLabel.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  RidesState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<RideSummary>? rides,
    String? query,
    String? statusFilter,
    bool clearStatusFilter = false,
  }) =>
      RidesState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        rides: rides ?? this.rides,
        query: query ?? this.query,
        statusFilter:
            clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      );

  @override
  List<Object?> get props =>
      [status, errorMessage, rides, query, statusFilter];
}
