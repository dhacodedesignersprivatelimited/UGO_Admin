import 'admin_staff_role.dart';
import 'rbac_policy.dart';

/// Temporary helper until JWT claims hydrate [AdminPrincipal] after login.
AdminPrincipal demoAdminPrincipal({
  AdminStaffRole role = AdminStaffRole.superAdmin,
}) {
  const policy = RbacPolicy();
  return policy.materialize(
    id: 'admin-demo',
    displayName: 'UGO Control',
    email: 'control@ugo.test',
    role: role,
  );
}
