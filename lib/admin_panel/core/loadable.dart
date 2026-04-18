import 'package:equatable/equatable.dart';

enum LoadStatus { idle, loading, success, failure }

class Loadable<T> extends Equatable {
  const Loadable({
    this.status = LoadStatus.idle,
    this.data,
    this.message,
  });

  final LoadStatus status;
  final T? data;
  final String? message;

  bool get isLoading => status == LoadStatus.loading;
  bool get hasData => data != null;
  bool get isFailure => status == LoadStatus.failure;

  Loadable<T> copyWith({
    LoadStatus? status,
    T? data,
    String? message,
  }) {
    return Loadable(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, data, message];
}
