import '/core/bloc/base_state.dart';

enum AuthStep { idle, submitting, success, failure }

class AuthState extends BlocBaseState {
  const AuthState({
    super.status = BlocLoadStatus.initial,
    super.errorMessage,
    this.email = '',
    this.passwordVisible = false,
    this.rememberMe = false,
  });

  final String email;
  final bool passwordVisible;
  final bool rememberMe;

  AuthState copyWith({
    BlocLoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? email,
    bool? passwordVisible,
    bool? rememberMe,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      email: email ?? this.email,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props =>
      [status, errorMessage, email, passwordVisible, rememberMe];
}
