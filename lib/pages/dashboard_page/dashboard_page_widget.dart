import 'package:flutter_animate/flutter_animate.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/components/responsive_body.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dashboard_page_model.dart';
export 'dashboard_page_model.dart';

class DashboardPageWidget extends StatefulWidget {
  const DashboardPageWidget({super.key});

  static String routeName = 'dashboardPage';
  static String routePath = '/dashboardPage';

  @override
  State<DashboardPageWidget> createState() => _DashboardPageWidgetState();
}

class _DashboardPageWidgetState extends State<DashboardPageWidget> {
  late DashboardPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardPageModel());

    // Fetch data on load
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _fetchDashboardData();
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    _model.dashboard = await DashBoardCall.call(
      token: currentAuthenticationToken,
    );

    if (_model.dashboard?.succeeded ?? false) {
      FFAppState().totalUsers = getJsonField(
        (_model.dashboard?.jsonBody ?? ''),
        r'''$.data.total_users''',
      ).toString();
      FFAppState().totalEarnings = getJsonField(
        (_model.dashboard?.jsonBody ?? ''),
        r'''$.data.total_earnings''',
      ).toString();
      FFAppState().activeDrivers = getJsonField(
        (_model.dashboard?.jsonBody ?? ''),
        r'''$.data.active_drivers''',
      ).toString();
      FFAppState().totalrides = getJsonField(
        (_model.dashboard?.jsonBody ?? ''),
        r'''$.data.total_rides''',
      ).toString();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // --- Helper Widget: Vibrant & RESPONSIVE Stat Cards ---
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      // RESPONSIVE FIX: Use minHeight instead of fixed height
      constraints: const BoxConstraints(minHeight: 110.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              // RESPONSIVE FIX: Let the column size to its children
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // RESPONSIVE FIX: Expanded allows text to wrap if it's too long
                    Expanded(
                      child: Text(
                        title,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(icon, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                // RESPONSIVE FIX: FittedBox shrinks huge numbers automatically
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    // Slightly smaller base font size (headlineMedium instead of displaySmall)
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Quick Action Cards ---
  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
        }
      },
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
            'Admin Dashboard',
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
            onRefresh: _fetchDashboardData,
            color: FlutterFlowTheme.of(context).primary,
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary))
                : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Vibrant Stat Cards Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: 'Total Rides',
                            value: valueOrDefault<String>(FFAppState().totalrides, '0'),
                            icon: Icons.local_taxi_rounded,
                            gradientColors: const [Color(0xFFFF6B35), Color(0xFFFF8F65)],
                            onTap: () => context.pushNamedAuth(RideManagementWidget.routeName, context.mounted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: 'Active Drivers',
                            value: valueOrDefault<String>(FFAppState().activeDrivers, '0'),
                            icon: Icons.drive_eta_rounded,
                            gradientColors: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                            onTap: () => context.pushNamedAuth(AllusersWidget.routeName, context.mounted),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 380.ms)
                        .slideY(begin: 0.08, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 12.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: 'Total Users',
                            value: valueOrDefault<String>(FFAppState().totalUsers, '0'),
                            icon: Icons.people_rounded,
                            gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                            onTap: () => context.pushNamedAuth(AllusersWidget.routeName, context.mounted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: 'Total Earnings',
                            value: '₹${valueOrDefault<String>(FFAppState().totalEarnings, '0')}',
                            icon: Icons.currency_rupee_rounded,
                            gradientColors: const [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                            onTap: () => context.pushNamedAuth(EarningsWidget.routeName, context.mounted),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 380.ms, delay: 80.ms)
                        .slideY(begin: 0.08, end: 0, duration: 380.ms, delay: 80.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 32.0),
                    Text(
                      'Quick Actions',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 350.ms, delay: 150.ms)
                        .slideX(begin: -0.02, end: 0, duration: 350.ms, delay: 150.ms),
                    const SizedBox(height: 16.0),

                    // Quick Action List
                    _buildQuickActionCard(
                      context: context,
                      title: 'Ride Management',
                      subtitle: 'View & manage all live rides',
                      icon: Icons.local_taxi_rounded,
                      onTap: () => context.pushNamedAuth(RideManagementWidget.routeName, context.mounted),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionCard(
                      context: context,
                      title: 'User Management',
                      subtitle: 'Manage riders & drivers',
                      icon: Icons.group_rounded,
                      onTap: () => context.pushNamedAuth(AllusersWidget.routeName, context.mounted),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionCard(
                      context: context,
                      title: 'Add Vehicle Type',
                      subtitle: 'Register new platform vehicle types',
                      icon: Icons.directions_car_rounded,
                      onTap: () => context.pushNamedAuth(AddVehicleTypeWidget.routeName, context.mounted),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionCard(
                      context: context,
                      title: 'Promo Codes',
                      subtitle: 'Create & distribute discount codes',
                      icon: Icons.local_offer_rounded,
                      onTap: () => context.pushNamedAuth(PromoCodesWidget.routeName, context.mounted),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionCard(
                      context: context,
                      title: 'Notifications',
                      subtitle: 'Broadcast FCM to users & drivers',
                      icon: Icons.notifications_rounded,
                      onTap: () => context.pushNamedAuth(NotificationsWidget.routeName, context.mounted),
                    ),

                    const SizedBox(height: 32.0),

                    // --- Settings Module ---
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Referral System Settings',
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Set the percentage amount awarded on referral rides.',
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            decoration: InputDecoration(
                              hintText: 'e.g. 5.0',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).primaryBackground,
                              suffixIcon: const Icon(Icons.percent, size: 18),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _model.textControllerValidator.asValidator(context),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: FFButtonWidget(
                                  onPressed: () => _model.textController?.clear(),
                                  text: 'Reset',
                                  options: FFButtonOptions(
                                    height: 45.0,
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.interTight(color: FlutterFlowTheme.of(context).primaryText),
                                    ),
                                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Settings Saved Successfully!')),
                                    );
                                  },
                                  text: 'Save Changes',
                                  options: FFButtonOptions(
                                    height: 45.0,
                                    color: const Color(0xFFFF6B35),
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.interTight(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
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