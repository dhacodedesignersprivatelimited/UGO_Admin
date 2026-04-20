import 'package:equatable/equatable.dart';

import '/core/utils/view_state.dart';
import '/modules/user_management/model/users_model.dart';

class UsersState extends Equatable with LoadStateMixin {
  const UsersState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.riders = const [],
    this.complaints = const [],
    this.query = '',
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<RiderListItem> riders;
  final List<dynamic> complaints;
  final String query;

  List<RiderListItem> get filtered {
    if (query.isEmpty) return riders;
    final q = query.toLowerCase();
    return riders
        .where((r) =>
            r.displayName.toLowerCase().contains(q) ||
            r.phone.contains(q))
        .toList();
  }

  UsersState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<RiderListItem>? riders,
    List<dynamic>? complaints,
    String? query,
  }) =>
      UsersState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        riders: riders ?? this.riders,
        complaints: complaints ?? this.complaints,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [status, errorMessage, riders, complaints, query];
}
