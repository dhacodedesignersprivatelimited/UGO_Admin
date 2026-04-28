import '../drivers_widget.dart';
import '/core/auth/auth_util.dart';
import '/core/network/api_config.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/safe_network_avatar.dart';
import '/shared/widgets/responsive_body.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'driver_kyc_list_model.dart';
export 'driver_kyc_list_model.dart';

class DriverKycListWidget extends StatefulWidget {
  const DriverKycListWidget({super.key});

  static String routeName = 'DriverKycList';
  static String routePath = '/driver-kyc-list';

  @override
  State<DriverKycListWidget> createState() => _DriverKycListWidgetState();
}

class _DriverKycListWidgetState extends State<DriverKycListWidget>
    with TickerProviderStateMixin {
  late DriverKycListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<ApiCallResponse> _driversFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverKycListModel());
    _tabController = TabController(length: 3, vsync: this);
    _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  String _normalizeKycStatus(dynamic driver) {
    final raw = getJsonField(driver, r'''$.kyc_status''')?.toString().trim() ?? '';
    final status = raw.toLowerCase();
    if (status.isEmpty) return 'pending';
    if (status == 'approved') return 'approved';
    if (status == 'rejected') return 'rejected';
    return 'pending';
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              'All Caught Up',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList(List<dynamic> drivers, String emptyMessage, IconData emptyIcon, Color emptyColor) {
    if (drivers.isEmpty) {
      return _buildEmptyState(emptyMessage, emptyIcon, emptyColor);
    }

    return ResponsiveContainer(
      maxWidth: 800,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final d = drivers[index];
          final firstName = getJsonField(d, r'''$.first_name''')?.toString() ?? '';
          final lastName = getJsonField(d, r'''$.last_name''')?.toString() ?? '';
          final name = '$firstName $lastName'.trim().isNotEmpty
              ? '$firstName $lastName'.trim()
              : 'Driver ${index + 1}';

          final vehicle = getJsonField(d, r'''$.vehicle_type''')?.toString() ??
              getJsonField(d, r'''$.vehicles[0].vehicle_model''')?.toString() ??
              'Vehicle unassigned';

          final phone = getJsonField(d, r'''$.mobile_number''')?.toString() ?? 'No phone provided';

          final img = getJsonField(d, r'''$.profile_image''')?.toString();
          final driverId = castToType<int>(getJsonField(d, r'''$.id'''));
          final statusStr = _normalizeKycStatus(d);

          Color badgeColor;
          Color badgeTextColor;
          String actionText = 'View Profile';

          if (statusStr == 'approved') {
            badgeColor = const Color(0xFFE8F5E9);
            badgeTextColor = const Color(0xFF2E7D32);
          } else if (statusStr == 'rejected') {
            badgeColor = const Color(0xFFFFEBEE);
            badgeTextColor = const Color(0xFFC62828);
          } else {
            badgeColor = const Color(0xFFFFF3E0);
            badgeTextColor = const Color(0xFFEF6C00);
            actionText = 'Review KYC';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: driverId != null
                    ? () => context.pushNamedAuth(
                  DriverLicenseWidget.routeName, // Keeping your original route
                  context.mounted,
                  queryParameters: {'userId': driverId.toString()},
                )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      SafeNetworkAvatar(
                        imageUrl: img != null && img.isNotEmpty && img != 'null'
                            ? (img.startsWith('http')
                            ? img
                            : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}')
                            : '',
                        radius: 32,
                      ),
                      const SizedBox(width: 16),

                      // Data Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                      font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                      color: FlutterFlowTheme.of(context).primaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    statusStr.toUpperCase(),
                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                      color: badgeTextColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.phone_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                const SizedBox(width: 4),
                                Text(
                                  phone,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.directions_car_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    vehicle,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action Section
                      if (MediaQuery.of(context).size.width > 500) ...[
                        const SizedBox(width: 16),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: statusStr == 'pending'
                                ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
                                : FlutterFlowTheme.of(context).secondaryBackground,
                            foregroundColor: statusStr == 'pending'
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).primaryText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: driverId != null
                              ? () => context.pushNamedAuth(
                            DriverLicenseWidget.routeName,
                            context.mounted,
                            queryParameters: {'userId': driverId.toString()},
                          )
                              : null,
                          child: Text(
                            actionText,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int count, Color highlightColor) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      fallbackRouteName: DriversWidget.routeName,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            onPressed: () => context.goNamedAuth(DriversWidget.routeName, context.mounted),
          ),
          title: Text(
            'KYC Verification Hub',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
              onPressed: () {
                setState(() {
                  _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
                });
              },
              tooltip: 'Refresh Queue',
            ),
          ],
          elevation: 0,
        ),
        body: FutureBuilder<ApiCallResponse>(
          future: _driversFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading verification queue...',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }

            final response = snapshot.data!;
            if (!response.succeeded) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline_rounded, size: 48, color: FlutterFlowTheme.of(context).error),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load KYC data',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final allDrivers = GetDriversCall.data(response.jsonBody)?.toList() ?? [];
            final pendingDrivers = allDrivers.where((d) => _normalizeKycStatus(d) == 'pending').toList();
            final approvedDrivers = allDrivers.where((d) => _normalizeKycStatus(d) == 'approved').toList();
            final rejectedDrivers = allDrivers.where((d) => _normalizeKycStatus(d) == 'rejected').toList();

            return Column(
              children: [
                // Modern Tab Bar Background
                Container(
                  width: double.infinity,
                  color: FlutterFlowTheme.of(context).primary,
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: FlutterFlowTheme.of(context).primary,
                        unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                        indicatorColor: FlutterFlowTheme.of(context).primary,
                        indicatorWeight: 3,
                        dividerColor: FlutterFlowTheme.of(context).alternate,
                        tabs: [
                          _buildTab('Pending', pendingDrivers.length, const Color(0xFFE65100)),
                          _buildTab('Approved', approvedDrivers.length, const Color(0xFF2E7D32)),
                          _buildTab('Rejected', rejectedDrivers.length, const Color(0xFFC62828)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab Views
                Expanded(
                  child: Container(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDriverList(
                          pendingDrivers,
                          'There are no pending KYC requests waiting in the queue.',
                          Icons.fact_check_outlined,
                          const Color(0xFFE65100),
                        ),
                        _buildDriverList(
                          approvedDrivers,
                          'No approved drivers found in the system.',
                          Icons.verified_user_outlined,
                          const Color(0xFF2E7D32),
                        ),
                        _buildDriverList(
                          rejectedDrivers,
                          'No rejected applications found.',
                          Icons.gpp_bad_outlined,
                          const Color(0xFFC62828),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}