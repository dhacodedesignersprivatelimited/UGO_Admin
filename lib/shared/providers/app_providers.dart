import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/shared/admin_panel_dependencies.dart';
import '/shared/admin_staff_role.dart';

/// Singleton composition root: holds all repository instances.
/// Override in tests with [ProviderScope(overrides: [...])].
final adminDepsProvider = Provider<AdminPanelDependencies>((ref) {
  return AdminPanelDependencies.http();
});

/// Currently authenticated admin principal.
/// Set to [AdminPrincipal.superAdmin()] before login; updated after login.
final adminPrincipalProvider = StateProvider<AdminPrincipal>((ref) {
  return AdminPrincipal.superAdmin();
});
