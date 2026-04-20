import 'package:equatable/equatable.dart';

class AdminNotificationDraft extends Equatable {
  const AdminNotificationDraft({
    required this.title,
    required this.body,
    this.targetSegment,
  });

  final String title;
  final String body;
  final String? targetSegment;

  @override
  List<Object?> get props => [title, body, targetSegment];
}

class AdminNotificationJob extends Equatable {
  const AdminNotificationJob({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, status, createdAt];
}
