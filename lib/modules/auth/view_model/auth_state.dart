import 'package:equatable/equatable.dart';

import '/core/utils/view_state.dart';

/// Immutable state for [AuthViewModel].
class AuthState extends Equatable with LoadStateMixin {
  const AuthState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.email = '',
    this.passwordVisible = false,
    this.rememberMe = false,
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final String email;
  final bool passwordVisible;
  final bool rememberMe;

  AuthState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? email,
    bool? passwordVisible,
    bool? rememberMe,
  }) =>
      AuthState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        email: email ?? this.email,
        passwordVisible: passwordVisible ?? this.passwordVisible,
        rememberMe: rememberMe ?? this.rememberMe,
      );

  @override
  List<Object?> get props =>
      [status, errorMessage, email, passwordVisible, rememberMe];
}
