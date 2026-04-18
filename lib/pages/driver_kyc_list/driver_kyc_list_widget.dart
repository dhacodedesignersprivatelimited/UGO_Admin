import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/components/admin_pop_scope.dart';
import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverKycListModel());
    _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _normalizeKycStatus(dynamic driver) {
    final raw =
        getJsonField(driver, r'''$.kyc_status''')?.toString().trim() ?? '';
    final status = raw.toLowerCase();
    if (status.isEmpty) return 'pending';
    if (status == 'approved') return 'approved';
    if (status == 'rejected') return 'rejected';
    return 'pending';
  }

  Widget _buildDriverList(List<dynamic> drivers, String emptyMessage) {
    if (drivers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.drive_eta_rounded,
                size: 64,
                color: FlutterFlowTheme.of(context).alternate,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.w500),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 40),
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
            '—';

        final img = getJsonField(d, r'''$.profile_image''')?.toString();
        final driverId = castToType<int>(getJsonField(d, r'''$.id'''));
        final statusStr = _normalizeKycStatus(d);

        Color badgeColor;
        Color badgeTextColor;
        if (statusStr == 'approved') {
          badgeColor = const Color(0xFFE8F5E9);
          badgeTextColor = const Color(0xFF2E7D32);
        } else if (statusStr == 'rejected') {
          badgeColor = const Color(0xFFFFEBEE);
          badgeTextColor = const Color(0xFFC62828);
        } else {
          badgeColor = const Color(0xFFFFF3E0);
          badgeTextColor = const Color(0xFFEF6C00);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: driverId != null
                  ? () => context.pushNamedAuth(
                        DriverLicenseWidget.routeName,
                        context.mounted,
                        queryParameters: {'userId': driverId.toString()},
                      )
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SafeNetworkAvatar(
                      imageUrl: img != null && img.isNotEmpty && img != 'null'
                          ? (img.startsWith('http')
                              ? img
                              : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}')
                          : '',
                      radius: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 16,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vehicle,
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusStr.toUpperCase(),
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold),
                              color: badgeTextColor,
                              fontSize: 10,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      fallbackRouteName: AllusersWidget.routeName,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 28),
            onPressed: () =>
                context.goNamedAuth(AllusersWidget.routeName, context.mounted),
          ),
          title: Text(
            'Driver KYC',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 24),
              onPressed: () {
                setState(() {
                  _driversFuture =
                      GetDriversCall.call(token: currentAuthenticationToken);
                });
              },
              tooltip: 'Refresh',
            ),
          ],
          elevation: 2,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                FlutterFlowTheme.of(context).primary.withValues(alpha:0.05),
                FlutterFlowTheme.of(context).secondaryBackground,
              ],
            ),
          ),
          child: FutureBuilder<ApiCallResponse>(
            future: _driversFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading drivers...',
                        style: FlutterFlowTheme.of(context).bodyMedium,
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
                        Icon(Icons.error_outline,
                            size: 48,
                            color: FlutterFlowTheme.of(context).error),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load drivers',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _driversFuture = GetDriversCall.call(
                                  token: currentAuthenticationToken);
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final allDrivers =
                  GetDriversCall.data(response.jsonBody)?.toList() ?? [];
              final pendingDrivers = allDrivers
                  .where((d) => _normalizeKycStatus(d) == 'pending')
                  .toList();
              final approvedDrivers = allDrivers
                  .where((d) => _normalizeKycStatus(d) == 'approved')
                  .toList();
              final rejectedDrivers = allDrivers
                  .where((d) => _normalizeKycStatus(d) == 'rejected')
                  .toList();

              return DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      child: TabBar(
                        labelColor: FlutterFlowTheme.of(context).primary,
                        unselectedLabelColor:
                            FlutterFlowTheme.of(context).secondaryText,
                        indicatorColor: FlutterFlowTheme.of(context).primary,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Pending'),
                                if (pendingDrivers.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withValues(alpha:0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${pendingDrivers.length}',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Approved'),
                                if (approvedDrivers.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withValues(alpha:0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${approvedDrivers.length}',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Rejected'),
                                if (rejectedDrivers.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withValues(alpha:0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${rejectedDrivers.length}',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildDriverList(
                              pendingDrivers, 'No pending KYC requests.'),
                          _buildDriverList(
                              approvedDrivers, 'No approved drivers found.'),
                          _buildDriverList(
                              rejectedDrivers, 'No rejected drivers found.'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
