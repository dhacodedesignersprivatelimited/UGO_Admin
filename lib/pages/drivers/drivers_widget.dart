import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart'; // Assumes DashboardPageWidget and DriverLicenseWidget are exported here
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'drivers_model.dart';
export 'drivers_model.dart';

class DriversWidget extends StatefulWidget {
  const DriversWidget({super.key});

  static String routeName = 'drivers';
  static String routePath = '/drivers';

  @override
  State<DriversWidget> createState() => _DriversWidgetState();
}

class _DriversWidgetState extends State<DriversWidget> {
  late DriversModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Store the future so it doesn't refetch every time you switch tabs
  late Future<ApiCallResponse> _driversFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriversModel());

    // Fetch once on init
    _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // --- Helper to build the filtered list ---
  Widget _buildDriverList(List<dynamic> drivers, String emptyMessage) {
    if (drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drive_eta_rounded, size: 64, color: FlutterFlowTheme.of(context).alternate),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800.0), // Responsive Constraint
        child: ListView.builder(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 40),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final d = drivers[index];
            final firstName = getJsonField(d, r'''$.first_name''')?.toString() ?? '';
            final lastName = getJsonField(d, r'''$.last_name''')?.toString() ?? '';
            final name = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : 'Driver ${index + 1}';

            final vehicle = getJsonField(d, r'''$.vehicle_type''')?.toString() ??
                getJsonField(d, r'''$.vehicles[0].vehicle_model''')?.toString() ?? '—';

            final img = getJsonField(d, r'''$.profile_image''')?.toString();
            final driverId = castToType<int>(getJsonField(d, r'''$.id'''));

            // Assume the API returns verification status (adjust field name if your API uses 'kyc_status')
            final statusStr = (getJsonField(d, r'''$.verification_status''')?.toString() ?? 'pending').toLowerCase();

            // Define Badge Colors based on status
            Color badgeColor;
            Color badgeTextColor;
            if (statusStr == 'approved') {
              badgeColor = const Color(0xFFE8F5E9); // Light Green
              badgeTextColor = const Color(0xFF2E7D32); // Dark Green
            } else if (statusStr == 'rejected') {
              badgeColor = const Color(0xFFFFEBEE); // Light Red
              badgeTextColor = const Color(0xFFC62828); // Dark Red
            } else {
              badgeColor = const Color(0xFFFFF3E0); // Light Orange
              badgeTextColor = const Color(0xFFEF6C00); // Dark Orange
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.pushNamedAuth(
                      DriverLicenseWidget.routeName,
                      context.mounted,
                      queryParameters: {'userId': firstName},
                    ),
                              child: Padding(
                      padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                            width: 60,
                            height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                              border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.3), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: (img != null && img.isNotEmpty && img != 'null')
                                  ? Image.network(
                                img.startsWith('http') ? img : 'https://ugotaxi.icacorp.org$img',
                                        fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: FlutterFlowTheme.of(context).primary, size: 30),
                              )
                                  : Icon(Icons.person, color: FlutterFlowTheme.of(context).primary, size: 30),
                            ),
                          ),
                          const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                  name,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.directions_car_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      vehicle,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(20),
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
                              const SizedBox(height: 8),
                              Icon(Icons.chevron_right_rounded, color: FlutterFlowTheme.of(context).primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                                ),
                              ),
                            ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        // Wrap with DefaultTabController to enable tabs
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            drawer: buildAdminDrawer(context),
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: true,
              foregroundColor: Colors.white,
              title: Text(
                'Driver Management',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              centerTitle: true,
              elevation: 0.0,
              // Add the TabBar to the AppBar
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(text: 'PENDING'),
                  Tab(text: 'APPROVED'),
                  Tab(text: 'REJECTED'),
                ],
              ),
            ),
            body: SafeArea(
              top: true,
              child: FutureBuilder<ApiCallResponse>(
                future: _driversFuture, // Using the stored future
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    );
                  }

                  final response = snapshot.data!;
                  if (!response.succeeded) {
                    return Center(
                      child: Text(
                        'Failed to load drivers.',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(color: FlutterFlowTheme.of(context).error),
                        ),
                      ),
                    );
                  }

                  final allDrivers = GetDriversCall.data(response.jsonBody)?.toList() ?? [];

                  // Filter the drivers based on their verification status
                  // (Defaults to 'pending' if the API field is null/missing)
                  final pendingDrivers = allDrivers.where((d) {
                    final status = (getJsonField(d, r'''$.verification_status''')?.toString() ?? 'pending').toLowerCase();
                    return status == 'pending';
                  }).toList();

                  final approvedDrivers = allDrivers.where((d) {
                    final status = (getJsonField(d, r'''$.verification_status''')?.toString() ?? 'pending').toLowerCase();
                    return status == 'approved';
                  }).toList();

                  final rejectedDrivers = allDrivers.where((d) {
                    final status = (getJsonField(d, r'''$.verification_status''')?.toString() ?? 'pending').toLowerCase();
                    return status == 'rejected';
                  }).toList();

                  // TabBarView must match the length of DefaultTabController
                  return TabBarView(
                    children: [
                      _buildDriverList(pendingDrivers, 'No pending KYC requests.'),
                      _buildDriverList(approvedDrivers, 'No approved drivers found.'),
                      _buildDriverList(rejectedDrivers, 'No rejected drivers found.'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}