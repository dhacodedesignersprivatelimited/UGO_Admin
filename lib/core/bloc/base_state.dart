import 'package:equatable/equatable.dart';

/// Canonical load status shared by every Cubit state.
enum BlocLoadStatus { initial, loading, success, failure }

/// Base class for all Cubit states. Extend this and add feature-specific fields.
abstract class BlocBaseState extends Equatable {
  const BlocBaseState({
    this.status = BlocLoadStatus.initial,
    this.errorMessage,
  });

  final BlocLoadStatus status;
  final String? errorMessage;

  bool get isInitial  => status == BlocLoadStatus.initial;
  bool get isLoading  => status == BlocLoadStatus.loading;
  bool get isSuccess  => status == BlocLoadStatus.success;
  bool get isFailure  => status == BlocLoadStatus.failure;
}
