import 'package:equatable/equatable.dart';

/// Mirrors backend `Admin` roles in [UGO_BACKEND/src/models/Admin.js].
enum AdminStaffRole {
  superAdmin('superadmin'),
  operations('operations'),
  driverAdmin('driver_admin'),
  customerSupport('customer_support'),
  finance('finance');

  const AdminStaffRole(this.apiValue);

  final String apiValue;

  static AdminStaffRole fromApiValue(String? raw) {
    if (raw == null || raw.isEmpty) return AdminStaffRole.customerSupport;
    final normalized = raw.trim().toLowerCase();
    for (final role in AdminStaffRole.values) {
      if (role.apiValue == normalized) return role;
    }
    return AdminStaffRole.customerSupport;
  }

  /// Product grouping: full admin vs support vs finance.
  bool get isFinanceOnly => this == AdminStaffRole.finance;

  bool get isSupportHeavy =>
      this == AdminStaffRole.customerSupport || this == AdminStaffRole.operations;
}

/// Fine-grained gates for UI + ViewModels. Map roles in [RbacPolicy].
enum AdminPermission {
  viewDashboard,
  manageRidesLive,
  manageDrivers,
  approveDriverKyc,
  controlDriverStatus,
  manageVehicles,
  viewDriverEarnings,
  approveWithdrawals,
  manageRiders,
  manageRiderWallets,
  manageComplaints,
  managePromoCodes,
  manageFareAndSurge,
  manageGlobalSettings,
  sendNotifications,
  manageSubAdmins,
}

class AdminPrincipal extends Equatable {
  const AdminPrincipal({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.permissions = const {},
  });

  /// Convenience factory used before the real user logs in.
  /// The [superAdmin] role bypasses all [can()] checks.
  factory AdminPrincipal.superAdmin() => const AdminPrincipal(
        id: 'system',
        displayName: 'Super Admin',
        email: '',
        role: AdminStaffRole.superAdmin,
      );

  final String id;
  final String displayName;
  final String email;
  final AdminStaffRole role;
  final Set<AdminPermission> permissions;

  bool can(AdminPermission permission) =>
      permissions.contains(permission) || role == AdminStaffRole.superAdmin;

  @override
  List<Object?> get props => [id, displayName, email, role, permissions];
}
