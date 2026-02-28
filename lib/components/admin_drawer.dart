import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

Widget buildAdminDrawer(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);

  return Drawer(
    backgroundColor: theme.secondaryBackground,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.primary, theme.secondary],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'UGO Admin',
                style: theme.headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Control Center',
                style: theme.bodySmall.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white.withValues(alpha:0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        _drawerSection(context, 'Operations'),
        _drawerItem(context, Icons.dashboard, 'Dashboard', () =>
            context.goNamedAuth(DashboardPageWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.local_taxi, 'Ride Management', () =>
            context.goNamedAuth(RideManagementWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.map, 'Live Driver Map', () =>
            context.goNamedAuth(LiveDriverMapWidget.routeName, context.mounted)),
        _drawerDivider(context),
        _drawerSection(context, 'Users & Drivers'),
        _drawerItem(context, Icons.people, 'All Users & Drivers', () =>
            context.goNamedAuth(AllusersWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.drive_eta, 'Drivers', () =>
            context.goNamedAuth(DriversWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.person_add, 'Add User', () =>
            context.goNamedAuth(AddUserWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.drive_eta, 'Add Driver', () =>
            context.goNamedAuth(AddDriverWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.block_rounded, 'Blocked Users', () =>
            context.goNamedAuth(BlockedUsersWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.verified_user, 'KYC Pending', () =>
            context.goNamedAuth(KycPendingWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.assignment_turned_in, 'Driver KYC List', () =>
            context.goNamedAuth(DriverKycListWidget.routeName, context.mounted)),
        _drawerDivider(context),
        _drawerSection(context, 'Finance'),
        _drawerItem(context, Icons.account_balance_wallet, 'Wallet Management', () =>
            context.goNamedAuth(WalletManagementWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.currency_exchange, 'Earnings', () =>
            context.goNamedAuth(EarningsWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.payments, 'Driver Payouts', () =>
            context.goNamedAuth(DriverPayoutsWidget.routeName, context.mounted)),
        _drawerDivider(context),
        _drawerSection(context, 'Settings & Pricing'),
        _drawerItem(context, Icons.attach_money, 'Fare & Surge', () =>
            context.goNamedAuth(FareSurgeSettingsWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.location_on, 'Zone Management', () =>
            context.goNamedAuth(ZoneManagementWidget.routeName, context.mounted)),
        _drawerDivider(context),
        _drawerSection(context, 'Vehicles'),
        _drawerItem(context, Icons.directions_car, 'Vehicle List', () =>
            context.goNamedAuth(VehiclesListWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.add_circle_outline, 'Add Vehicle', () =>
            context.goNamedAuth(AddVehicleWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.category, 'Add Vehicle Type', () =>
            context.goNamedAuth(AddVehicleTypeWidget.routeName, context.mounted)),
        _drawerDivider(context),
        _drawerSection(context, 'Marketing'),
        _drawerItem(context, Icons.card_giftcard, 'Incentives', () =>
            context.goNamedAuth(IncentivesWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.add_circle, 'Add Incentive', () =>
            context.goNamedAuth(AddIncentiveWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.local_offer, 'Promo Codes', () =>
            context.goNamedAuth(PromoCodesWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.notifications_active, 'Notifications', () =>
            context.goNamedAuth(NotificationsWidget.routeName, context.mounted)),
        _drawerDivider(context),
        _drawerSection(context, 'Feedback'),
        _drawerItem(context, Icons.star, 'Reviews', () =>
            context.goNamedAuth(ReviewsWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.feedback, 'User Complaints', () =>
            context.goNamedAuth(UserComplaintsWidget.routeName, context.mounted)),
        _drawerDivider(context),
        _drawerSection(context, 'Admin'),
        _drawerItem(context, Icons.admin_panel_settings, 'Sub-Admins', () =>
            context.goNamedAuth(SubAdminsWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.settings, 'App Settings', () =>
            context.goNamedAuth(AppSettingsWidget.routeName, context.mounted)),
        _drawerItem(context, Icons.account_circle, 'Account', () =>
            context.goNamedAuth(AccountWidget.routeName, context.mounted)),
      ],
    ),
  );
}

Widget _drawerSection(BuildContext context, String title) {
  final theme = FlutterFlowTheme.of(context);
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      title,
      style: theme.labelMedium.override(
        font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
        color: theme.secondaryText,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    ),
  );
}

Widget _drawerDivider(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);
  return Divider(
    height: 1,
    indent: 16,
    endIndent: 16,
    color: theme.alternate,
  );
}

Widget _drawerItem(
  BuildContext context,
  IconData icon,
  String label,
  VoidCallback onTap,
) {
  final theme = FlutterFlowTheme.of(context);
  return ListTile(
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    leading: Icon(icon, color: theme.primary, size: 22),
    title: Text(
      label,
      style: theme.titleSmall.override(
        font: GoogleFonts.inter(fontWeight: FontWeight.w500),
        fontSize: 14,
      ),
    ),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}
