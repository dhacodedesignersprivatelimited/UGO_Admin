import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/admin_staff_role.dart';
import '/shared/providers/app_providers.dart';
import '/core/utils/view_state.dart';
import 'auth_state.dart';

export 'auth_state.dart';

/// ViewModel for the login screen.
/// Responsible for field state + calling [LoginAdminCall].
class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._ref) : super(const AuthState());

  final Ref _ref;

  // ── Field helpers ─────────────────────────────────────────

  void updateEmail(String value) => state = state.copyWith(email: value);

  void togglePasswordVisible() =>
      state = state.copyWith(passwordVisible: !state.passwordVisible);

  void updateRememberMe(bool value) =>
      state = state.copyWith(rememberMe: value);

  void resetStatus() =>
      state = state.copyWith(status: LoadStatus.initial, clearError: true);

  // ── Login ─────────────────────────────────────────────────

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final res = await LoginCall.call(email: email, password: password);
      if (!(res.succeeded ?? false)) {
        state = state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Login failed.',
        );
        return;
      }

      final token = LoginCall.accessToken(res.jsonBody);
      if (token == null) {
        state = state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'No token returned from server.',
        );
        return;
      }

      // Persist token via existing auth manager.
      await authManager.signIn(authenticationToken: token);

      // Update global principal with actual user data.
      final userData = LoginCall.admin(res.jsonBody);
      if (userData is Map) {
        final principal = AdminPrincipal(
          id: userData['id']?.toString() ?? '',
          displayName: userData['name']?.toString() ?? 'Admin',
          email: userData['email']?.toString() ?? '',
          role: AdminStaffRole.fromApiValue(userData['role']?.toString()),
        );
        _ref.read(adminPrincipalProvider.notifier).state = principal;
      }

      state = state.copyWith(status: LoadStatus.success, clearError: true);
    } catch (e) {
      state = state.copyWith(
        status: LoadStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Logout ────────────────────────────────────────────────

  Future<void> logout() async {
    await authManager.signOut();
    _ref.read(adminPrincipalProvider.notifier).state =
        AdminPrincipal.superAdmin();
    state = const AuthState();
  }
}

/// The single global [AuthViewModel] provider.
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref);
});
