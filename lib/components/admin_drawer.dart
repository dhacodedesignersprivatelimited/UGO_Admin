import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;
}

class _NavSection {
  const _NavSection(this.title, this.items);

  final String title;
  final List<_NavItem> items;
}

String? _currentRouteName(BuildContext context) {
  try {
    return GoRouterState.of(context).name;
  } catch (_) {
    return null;
  }
}

Widget buildAdminDrawer(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);
  final selectedName = _currentRouteName(context);
  final uid = currentUser?.uid;

  final sections = <_NavSection>[
    _NavSection('Operations', [
      _NavItem(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        routeName: DashboardScreen.routeName,
      ),
      _NavItem(
        icon: Icons.local_taxi_rounded,
        label: 'Ride management',
        routeName: RideManagementWidget.routeName,
      ),
      _NavItem(
        icon: Icons.map_rounded,
        label: 'Live driver map',
        routeName: LiveDriverMapWidget.routeName,
      ),
    ]),
    _NavSection('Users & drivers', [
      _NavItem(
        icon: Icons.groups_rounded,
        label: 'All users & drivers',
        routeName: AllusersWidget.routeName,
      ),
      _NavItem(
        icon: Icons.drive_eta_rounded,
        label: 'Drivers',
        routeName: DriversWidget.routeName,
      ),
      _NavItem(
        icon: Icons.person_add_rounded,
        label: 'Add user',
        routeName: AddUserWidget.routeName,
      ),
      _NavItem(
        icon: Icons.badge_rounded,
        label: 'Add driver',
        routeName: AddDriverWidget.routeName,
      ),
      _NavItem(
        icon: Icons.block_rounded,
        label: 'Blocked users',
        routeName: BlockedUsersWidget.routeName,
      ),
      _NavItem(
        icon: Icons.verified_user_rounded,
        label: 'KYC pending',
        routeName: KycPendingWidget.routeName,
      ),
      _NavItem(
        icon: Icons.fact_check_rounded,
        label: 'Driver KYC list',
        routeName: DriverKycListWidget.routeName,
      ),
    ]),
    _NavSection('Finance', [
      _NavItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet management',
        routeName: WalletManagementWidget.routeName,
      ),
      _NavItem(
        icon: Icons.currency_exchange_rounded,
        label: 'Earnings',
        routeName: EarningsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.payments_rounded,
        label: 'Driver payouts',
        routeName: DriverPayoutsWidget.routeName,
      ),
    ]),
    _NavSection('Settings & pricing', [
      _NavItem(
        icon: Icons.tune_rounded,
        label: 'Fare & surge',
        routeName: FareSurgeSettingsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.map_outlined,
        label: 'Zone management',
        routeName: ZoneManagementWidget.routeName,
      ),
    ]),
    _NavSection('Vehicles', [
      _NavItem(
        icon: Icons.directions_car_rounded,
        label: 'Vehicle list',
        routeName: VehiclesListWidget.routeName,
      ),
      _NavItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add vehicle',
        routeName: AddVehicleWidget.routeName,
      ),
      _NavItem(
        icon: Icons.category_rounded,
        label: 'Add vehicle type',
        routeName: AddVehicleTypeWidget.routeName,
      ),
    ]),
    _NavSection('Marketing', [
      _NavItem(
        icon: Icons.card_giftcard_rounded,
        label: 'Incentives',
        routeName: IncentivesWidget.routeName,
      ),
      _NavItem(
        icon: Icons.add_circle_rounded,
        label: 'Add incentive',
        routeName: AddIncentiveWidget.routeName,
      ),
      _NavItem(
        icon: Icons.local_offer_rounded,
        label: 'Promo codes',
        routeName: PromoCodesWidget.routeName,
      ),
      _NavItem(
        icon: Icons.notifications_active_rounded,
        label: 'Notifications',
        routeName: NotificationsWidget.routeName,
      ),
    ]),
    _NavSection('Feedback', [
      _NavItem(
        icon: Icons.star_rounded,
        label: 'Reviews',
        routeName: ReviewsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.support_agent_rounded,
        label: 'User complaints',
        routeName: UserComplaintsWidget.routeName,
      ),
    ]),
    _NavSection('Admin', [
      _NavItem(
        icon: Icons.admin_panel_settings_rounded,
        label: 'Sub-admins',
        routeName: SubAdminsWidget.routeName,
      ),
      _NavItem(
        icon: Icons.settings_rounded,
        label: 'App settings',
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
                for (var s = 0; s < sections.length; s++) ...[
                  if (s > 0) _DrawerDivider(theme: theme),
                  _DrawerSectionTitle(theme: theme, title: sections[s].title),
                  for (final item in sections[s].items)
                    _DrawerNavTile(
                      theme: theme,
                      icon: item.icon,
                      label: item.label,
                      routeName: item.routeName,
                      selected: selectedName == item.routeName,
                      onTap: () {
                        Navigator.pop(context);
                        context.goNamedAuth(
                          item.routeName,
                          context.mounted,
                        );
                      },
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
                  'UGO Admin',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Control center',
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

class _DrawerSectionTitle extends StatelessWidget {
  const _DrawerSectionTitle({
    required this.theme,
    required this.title,
  });

  final FlutterFlowTheme theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
          letterSpacing: 0.9,
          color: theme.secondaryText,
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider({required this.theme});

  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: theme.alternate.withValues(alpha: 0.65),
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
  });

  final FlutterFlowTheme theme;
  final IconData icon;
  final String label;
  final String routeName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? theme.primary.withValues(alpha: 0.1)
        : Colors.transparent;
    final fg = selected ? theme.primary : theme.primaryText;
    final iconColor = selected ? theme.primary : theme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: Icon(icon, color: iconColor, size: 22),
          title: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              color: fg,
            ),
          ),
          trailing: selected
              ? Icon(Icons.chevron_right_rounded, color: theme.primary, size: 20)
              : null,
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
        leading: Icon(Icons.logout_rounded, color: theme.error, size: 22),
        title: Text(
          'Sign out',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: theme.error,
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sign out'),
              content: const Text('End your session and return to the login screen?'),
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
