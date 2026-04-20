import 'package:equatable/equatable.dart';
import '/core/utils/view_state.dart';

class NotificationsState extends Equatable with LoadStateMixin {
  const NotificationsState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.title = '',
    this.body = '',
    this.targetAudience = 'all',
    this.sentCount = 0,
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final String title;
  final String body;
  final String targetAudience;
  final int sentCount;

  NotificationsState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? title,
    String? body,
    String? targetAudience,
    int? sentCount,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        title: title ?? this.title,
        body: body ?? this.body,
        targetAudience: targetAudience ?? this.targetAudience,
        sentCount: sentCount ?? this.sentCount,
      );

  @override
  List<Object?> get props =>
      [status, errorMessage, title, body, targetAudience, sentCount];
}
