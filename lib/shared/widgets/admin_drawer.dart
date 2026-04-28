import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../modules/finance/screens/earnings_screen.dart';
import '../../modules/finance/screens/finance_reports_screen.dart';
import '/core/auth/auth_util.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';

abstract class _DrawerNode {}

class _NavItem extends _DrawerNode {
  _NavItem({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;
}

class _NavSection extends _DrawerNode {
  _NavSection(this.title, this.icon, this.items);

  final String title;
  final IconData icon;
  final List<_NavItem> items;
}

String? _currentRouteName(BuildContext context) {
  try {
    return GoRouterState.of(context).name;
  } catch (_) {
    return null;
  }
}

/// Detail screens pushed on the stack should highlight their parent section in the drawer.
String? _drawerHighlightForRoute(String? currentName) {
  if (currentName == null || currentName.isEmpty) return null;
  if (currentName == DriverDetailsWidget.routeName ||
      currentName == DriverLicenseWidget.routeName) {
    return DriversWidget.routeName;
  }
  if (currentName == UserDetailsWidget.routeName) {
    return AllusersWidget.routeName;
  }
  if (currentName == RideDetailsWidget.routeName) {
    return RideManagementScreen.routeName;
  }
  if (currentName == IncentiveDetailsWidget.routeName) {
    return IncentivesWidget.routeName;
  }
  return currentName;
}

Widget buildAdminDrawer(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);
  final selectedName = _drawerHighlightForRoute(_currentRouteName(context));
  final uid = currentUser?.uid;

  final nodes = <_DrawerNode>[
    _NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      routeName: DashboardScreen.routeName,
    ),
    _NavSection('User Management', Icons.manage_accounts_rounded, [
      _NavItem(
        icon: Icons.manage_accounts_rounded,
        label: 'User Dashboard',
        routeName: UserManagementWidget.routeName,
      ),
      _NavItem(
        icon: Icons.block_rounded,
        label: 'Blocked Users',
        routeName: BlockedUsersWidget.routeName,
      ),
      _NavItem(
        icon: Icons.person_add_rounded,
        label: 'Add User',
        routeName: AddUserWidget.routeName,
      ),
      _NavItem(
        icon: Icons.support_agent_rounded,
        label: 'User Complaints',
        routeName: UserComplaintsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.star_rounded,
        label: 'User Reviews',
        routeName: ReviewsWidget.routeName,
      ),
    ]),
    _NavSection('Driver Management', Icons.drive_eta_rounded, [
      _NavItem(
        icon: Icons.recent_actors_rounded,
        label: 'Drivers Dashboard',
        routeName: DriversWidget.routeName,
      ),
      _NavItem(
        icon: Icons.fact_check_rounded,
        label: 'Driver KYC List',
        routeName: DriverKycListWidget.routeName,
      ),
      // _NavItem(
      //   icon: Icons.map_rounded,
      //   label: 'Online Drivers',
      //   routeName: LiveDriverMapWidget.routeName,
      // ),

      _NavItem(
        icon: Icons.support_agent_rounded,
        label: 'Driver Complaints',
        routeName: DriverComplaintsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.star_rounded,
        label: 'Driver Reviews',
        routeName: DriverReviewsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.badge_rounded,
        label: 'Add Driver',
        routeName: AddDriverWidget.routeName,
      ),
      _NavItem(
        icon: Icons.block_rounded,
        label: 'Blocked Drivers',
        routeName: BlockedDriversWidget.routeName,
      ),
    ]),
    _NavSection('Ride Management', Icons.local_taxi_rounded, [
      _NavItem(
        icon: Icons.route_rounded,
        label: 'Ride Dashboard',
        routeName: RideManagementScreen.routeName,
      ),
    ]),
    _NavSection(
      'Wallet & Finance',
      Icons.account_balance_wallet_rounded,
      [
        _NavItem(
          icon: Icons.dashboard_customize_rounded,
          label: 'Dashboard',
          routeName: WalletManagementWidget.routeName,
        ),
        _NavItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Wallets',
          routeName: WalletsScreen.routeName,
        ),
        _NavItem(
          icon: Icons.receipt_long_rounded,
          label: 'Transactions',
          routeName: WalletTransactionsScreen.routeName,
        ),
        _NavItem(
          icon: Icons.currency_exchange_rounded,
          label: 'Earnings',
          routeName: EarningsScreen.routeName,
        ),
        _NavItem(
          icon: Icons.payments_rounded,
          label: 'Payouts',
          routeName: DriverPayoutsWidget.routeName,
        ),
        _NavItem(
          icon: Icons.bar_chart_rounded,
          label: 'Reports',
          routeName: FinanceReportsScreen.routeName,
        ),
        _NavItem(
          icon: Icons.tune_rounded,
          label: 'Adjust',
          routeName: WalletAdjustScreen.routeName,
        ),
      ],
    ),
    _NavSection('Vehicle Management', Icons.directions_car_rounded, [
      _NavItem(
        icon: Icons.category_rounded,
        label: 'Vehicles List',
        routeName: VehiclesListWidget.routeName,
      ),
      _NavItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add Vehicle',
        routeName: AddVehicleWidget.routeName,
      ),
      _NavItem(
        icon: Icons.library_add_rounded,
        label: 'Add Vehicle Type',
        routeName: AddVehicleTypeWidget.routeName,
      ),
    ]),
    _NavSection('Area & Zone Management', Icons.map_outlined, [
      _NavItem(
        icon: Icons.share_location_rounded,
        label: 'Zones List',
        routeName: ZoneManagementWidget.routeName,
      ),
      _NavItem(
        icon: Icons.tune_rounded,
        label: 'Fare & Surge',
        routeName: FareSurgeSettingsWidget.routeName,
      ),
    ]),
    _NavSection('Marketing & Feedback', Icons.campaign_rounded, [
      _NavItem(
        icon: Icons.card_giftcard_rounded,
        label: 'Incentives',
        routeName: IncentivesWidget.routeName,
      ),
      _NavItem(
        icon: Icons.add_circle_rounded,
        label: 'Add Incentive',
        routeName: AddIncentiveWidget.routeName,
      ),
      _NavItem(
        icon: Icons.local_offer_rounded,
        label: 'Promo Codes',
        routeName: PromoCodesWidget.routeName,
      ),
      _NavItem(
        icon: Icons.notifications_active_rounded,
        label: 'Notifications',
        routeName: NotificationsWidget.routeName,
      ),
    ]),
    _NavSection('System Admin', Icons.admin_panel_settings_rounded, [
      _NavItem(
        icon: Icons.manage_accounts_outlined,
        label: 'Sub-admins',
        routeName: SubAdminsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.settings_rounded,
        label: 'App Settings',
        routeName: AppSettingsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.account_circle_rounded,
        label: 'Account',
        routeName: AccountWidget.routeName,
      ),
    ]),
  ];

  return Drawer(
    backgroundColor: theme.secondaryBackground,
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DrawerBranding(theme: theme, uid: uid),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                for (final node in nodes) ...[
                  if (node is _NavItem)
                    _DrawerNavTile(
                      theme: theme,
                      icon: node.icon,
                      label: node.label,
                      routeName: node.routeName,
                      selected: selectedName == node.routeName,
                      isSubItem: false,
                      onTap: () {
                        Navigator.pop(context);
                        context.goNamedAuth(
                          node.routeName,
                          context.mounted,
                        );
                      },
                    )
                  else if (node is _NavSection)
                    _DrawerExpandableSection(
                      theme: theme,
                      section: node,
                      selectedName: selectedName,
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          _DrawerSignOutButton(theme: theme),
        ],
      ),
    ),
  );
}

class _DrawerExpandableSection extends StatelessWidget {
  const _DrawerExpandableSection({
    required this.theme,
    required this.section,
    required this.selectedName,
  });

  final FlutterFlowTheme theme;
  final _NavSection section;
  final String? selectedName;

  @override
  Widget build(BuildContext context) {
    final hasSelectedItem =
        section.items.any((item) => item.routeName == selectedName);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: hasSelectedItem,
        leading: Icon(
          section.icon,
          color: hasSelectedItem ? theme.primary : theme.primaryText,
          size: 24,
        ),
        title: Text(
          section.title,
          style: GoogleFonts.inter(
            fontWeight: hasSelectedItem ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
            color: hasSelectedItem ? theme.primary : theme.primaryText,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
        children: section.items.map((item) {
          return _DrawerNavTile(
            theme: theme,
            icon: item.icon,
            label: item.label,
            routeName: item.routeName,
            selected: selectedName == item.routeName,
            isSubItem: true,
            onTap: () {
              Navigator.pop(context);
              context.goNamedAuth(
                item.routeName,
                context.mounted,
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _DrawerBranding extends StatelessWidget {
  const _DrawerBranding({
    required this.theme,
    this.uid,
  });

  final FlutterFlowTheme theme;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.goNamedAuth(DashboardScreen.routeName, context.mounted);
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primary,
                Color.lerp(theme.primary, theme.secondary, 0.35)!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'UGO TAXI',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Control Center',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (uid != null && uid!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Admin ID · $uid',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.theme,
    required this.icon,
    required this.label,
    required this.routeName,
    required this.selected,
    required this.onTap,
    this.isSubItem = false,
  });

  final FlutterFlowTheme theme;
  final IconData icon;
  final String label;
  final String routeName;
  final bool selected;
  final VoidCallback onTap;
  final bool isSubItem;

  @override
  Widget build(BuildContext context) {
    final bg =
        selected ? theme.primary.withValues(alpha: 0.1) : Colors.transparent;
    final fg = selected ? theme.primary : theme.primaryText;
    final iconColor = selected ? theme.primary : theme.secondaryText;

    final double iconSize = isSubItem ? 20 : 24;
    final double fontSize = isSubItem ? 13 : 15;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          dense: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: isSubItem ? 16 : 12, vertical: 0),
          leading: Icon(icon, color: iconColor, size: iconSize),
          title: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: fontSize,
              color: fg,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _DrawerSignOutButton extends StatelessWidget {
  const _DrawerSignOutButton({required this.theme});

  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(Icons.logout_rounded, color: theme.error, size: 24),
        title: Text(
          'Sign out',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: theme.error,
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign out'),
              content: const Text(
                  'End your session and return to the login screen?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Sign out',
                    style: TextStyle(color: theme.error),
                  ),
                ),
              ],
            ),
          );
          if (confirm != true || !context.mounted) return;
          final router = GoRouter.of(context);
          router.prepareAuthEvent();
          await authManager.signOut();
          router.clearRedirectLocation();
          if (!context.mounted) return;
          context.goNamedAuth(LoginWidget.routeName, context.mounted);
        },
      ),
    );
  }
}
