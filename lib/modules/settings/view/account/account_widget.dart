import '/core/auth/auth_util.dart';
import '/core/network/api_config.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart'; // Assumes navigation targets are exported here
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'account_model.dart';
export 'account_model.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  static String routeName = 'Account';
  static String routePath = '/account';

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  late AccountModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  String _adminName = 'Admin User';
  String _adminEmail = '';
  String _adminRole = '';
  String? _adminAvatar;
  String? _adminPhone;
  String? _walletBalance;
  String? _lastLogin;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccountModel());

    // Fetch Admin Profile on Page Load
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _fetchAdminProfile();
    });
  }

  Future<void> _fetchAdminProfile() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      _model.profileResponse = await GetProfileCall.call(
        token: currentAuthenticationToken,
      );

      if (mounted && (_model.profileResponse?.succeeded ?? false)) {
        final json = _model.profileResponse?.jsonBody ?? '';
        final data = getJsonField(json, r'''$.data''');
        String? avatarPath = getJsonField(data, r'''$.profileImage''')?.toString();
        if (avatarPath != null && avatarPath.isNotEmpty && avatarPath != 'null') {
          avatarPath = avatarPath.startsWith('http') ? avatarPath : '${ApiConfig.baseUrl}/$avatarPath';
        }
        setState(() {
          _adminName = getJsonField(data, r'''$.adminName''')?.toString() ?? 'Admin User';
          _adminEmail = getJsonField(data, r'''$.email''')?.toString() ?? '';
          _adminRole = getJsonField(data, r'''$.role''')?.toString() ?? '';
          _adminAvatar = avatarPath;
          _adminPhone = getJsonField(data, r'''$.phoneNumber''')?.toString();
          _walletBalance = getJsonField(data, r'''$.wallet_balance''')?.toString();
          _lastLogin = getJsonField(data, r'''$.lastLogin''')?.toString();
        });
      }
    } catch (e) {
      if (mounted) debugPrint('Error fetching profile: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.white.withValues(alpha:0.3),
      child: Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // --- Helper Widget: Categorized Setting Tiles ---
  Widget _buildActionTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.02),
              blurRadius: 5.0,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha:0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.0),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: FlutterFlowTheme.of(context).secondaryText),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Section Header ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: FlutterFlowTheme.of(context).labelMedium.override(
          font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
          color: FlutterFlowTheme.of(context).primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: buildAdminDrawer(context),
        appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: Colors.white,
          title: Text(
              'Account Settings',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
            child: RefreshIndicator(
              onRefresh: _fetchAdminProfile,
              color: FlutterFlowTheme.of(context).primary,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary))
                  : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800.0), // Responsive constraint
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Vibrant Profile Header ---
                            Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                              decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FlutterFlowTheme.of(context).primary,
                                const Color(0xFFFF8F65), // Secondary vibrant color
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                              children: [
                              Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha:0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: ClipOval(
                                  child: _adminAvatar != null &&
                                          _adminAvatar!.isNotEmpty
                                      ? Image.network(
                                          _adminAvatar!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _buildDefaultAvatar(),
                                        )
                                      : _buildDefaultAvatar(),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                                Text(
                                _adminName,
                                style: FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                  color: Colors.white,
                                ),
                              ),
                                          Text(
                                _adminEmail,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: Colors.white.withValues(alpha:0.9),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              if (_adminRole.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.2),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    _adminRole.toUpperCase(),
                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                      font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              if (_adminPhone != null && _adminPhone!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                          Text(
                                  _adminPhone!,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Colors.white.withValues(alpha:0.9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // --- Settings List ---
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                                      child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                              // SECTION 1
                              _buildSectionHeader('Fleet & Users'),
                              const SizedBox(height: 12),
                              _buildActionTile(
                                title: 'Add Vehicles',
                                subtitle: 'Register new vehicle types (Bike, Auto)',
                                icon: Icons.directions_car_rounded,
                                iconBgColor: Colors.orange,
                                iconColor: Colors.orange,
                                onTap: () => context.pushNamedAuth(AddVehicleWidget.routeName, context.mounted),
                              ),
                              const SizedBox(height: 12),
                              _buildActionTile(
                                title: 'Blocked Users',
                                subtitle: 'Manage restricted platform access',
                                icon: Icons.block_rounded,
                                iconBgColor: Colors.red,
                                iconColor: Colors.red,
                                onTap: () => context.pushNamedAuth(BlockedUsersWidget.routeName, context.mounted),
                              ),

                              // SECTION 2
                              _buildSectionHeader('Platform Setup'),
                              _buildActionTile(
                                title: 'Incentives & Rewards',
                                subtitle: 'Manage driver bonuses',
                                icon: Icons.card_giftcard_rounded,
                                iconBgColor: Colors.green,
                                iconColor: Colors.green,
                                onTap: () => context.pushNamedAuth(IncentivesWidget.routeName, context.mounted),
                              ),
                              const SizedBox(height: 12),
                              _buildActionTile(
                                title: 'Push Notifications',
                                subtitle: 'Broadcast alerts to users & drivers',
                                icon: Icons.notifications_active_rounded,
                                iconBgColor: Colors.purple,
                                iconColor: Colors.purple,
                                onTap: () => context.pushNamedAuth(NotificationsWidget.routeName, context.mounted),
                              ),

                              // SECTION 3
                              _buildSectionHeader('Support & Feedback'),
                              _buildActionTile(
                                title: 'User Complaints',
                                subtitle: 'Resolve ride disputes and issues',
                                icon: Icons.report_problem_rounded,
                                iconBgColor: Colors.deepOrange,
                                iconColor: Colors.deepOrange,
                                onTap: () => context.pushNamedAuth(UserComplaintsWidget.routeName, context.mounted),
                              ),
                              const SizedBox(height: 12),
                              _buildActionTile(
                                title: 'App Reviews',
                                subtitle: 'Monitor platform feedback',
                                icon: Icons.star_rounded,
                                iconBgColor: Colors.amber,
                                iconColor: Colors.amber.shade700,
                                onTap: () => context.pushNamedAuth(ReviewsWidget.routeName, context.mounted),
                              ),

                              // SECTION 4
                              _buildSectionHeader('Security'),
                              _buildActionTile(
                                title: 'Logout',
                                subtitle: 'Securely end your admin session',
                                icon: Icons.logout_rounded,
                                iconBgColor: Colors.grey,
                                iconColor: Colors.grey.shade700,
                                onTap: () async {
                                  // Confirm Logout Dialog
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text('Are you sure you want to end your session?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                GoRouter.of(context).prepareAuthEvent();
                                await authManager.signOut();
                                GoRouter.of(context).clearRedirectLocation();
                                    if (context.mounted) {
                                      context.goNamedAuth(LoginWidget.routeName, context.mounted);
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 40.0), // Bottom padding
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}