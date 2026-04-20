import 'admin_staff_role.dart';

/// Central policy for role → permission mapping. Adjust to match your API contract.
class RbacPolicy {
  const RbacPolicy();

  Set<AdminPermission> permissionsFor(AdminStaffRole role) {
    switch (role) {
      case AdminStaffRole.superAdmin:
        return {...AdminPermission.values};
      case AdminStaffRole.operations:
        return {
          AdminPermission.viewDashboard,
          AdminPermission.manageRidesLive,
          AdminPermission.manageDrivers,
          AdminPermission.controlDriverStatus,
          AdminPermission.manageVehicles,
          AdminPermission.sendNotifications,
        };
      case AdminStaffRole.driverAdmin:
        return {
          AdminPermission.viewDashboard,
          AdminPermission.manageDrivers,
          AdminPermission.approveDriverKyc,
          AdminPermission.controlDriverStatus,
          AdminPermission.manageVehicles,
          AdminPermission.viewDriverEarnings,
        };
      case AdminStaffRole.customerSupport:
        return {
          AdminPermission.viewDashboard,
          AdminPermission.manageRidesLive,
          AdminPermission.manageRiders,
          AdminPermission.manageComplaints,
          AdminPermission.sendNotifications,
        };
      case AdminStaffRole.finance:
        return {
          AdminPermission.viewDashboard,
          AdminPermission.viewDriverEarnings,
          AdminPermission.approveWithdrawals,
          AdminPermission.manageRiderWallets,
          AdminPermission.managePromoCodes,
          AdminPermission.manageFareAndSurge,
        };
    }
  }

  AdminPrincipal materialize({
    required String id,
    required String displayName,
    required String email,
    required AdminStaffRole role,
    Set<AdminPermission>? extraPermissions,
  }) {
    final base = permissionsFor(role);
    final merged = {...base, ...?extraPermissions};
    return AdminPrincipal(
      id: id,
      displayName: displayName,
      email: email,
      role: role,
      permissions: merged,
    );
  }
}
