import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_config.dart';
import '/components/admin_drawer.dart';
import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  late Future<ApiCallResponse> _driversFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriversModel());
    _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _refreshDrivers() async {
    final future = GetDriversCall.call(token: currentAuthenticationToken);
    setState(() => _driversFuture = future);
    final response = await future;
    if (!response.succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not refresh drivers')),
      );
    }
  }

  List<dynamic> _extractDrivers(dynamic jsonBody) {
    final direct = GetDriversCall.data(jsonBody);
    if (direct is List) return direct;
    final nested = getJsonField(jsonBody, r'''$.data.drivers''');
    if (nested is List) return nested;
    final alt = getJsonField(jsonBody, r'''$.drivers''');
    if (alt is List) return alt;
    return [];
  }

  String _normalizeKycStatus(dynamic driver) {
    final kyc =
        getJsonField(driver, r'''$.kyc_status''')?.toString().trim() ?? '';
    if (kyc.isNotEmpty && kyc != 'null') {
      final s = kyc.toLowerCase();
      if (s == 'approved') return 'approved';
      if (s == 'rejected' || s == 'declined') return 'rejected';
      return 'pending';
    }
    final ver = getJsonField(driver, r'''$.verification_status''')
            ?.toString()
            .trim() ??
        '';
    if (ver.isNotEmpty && ver != 'null') {
      final s = ver.toLowerCase();
      if (s == 'approved') return 'approved';
      if (s == 'rejected' || s == 'declined') return 'rejected';
      return 'pending';
    }
    return 'pending';
  }

  String _driverName(dynamic d, int index) {
    final first = getJsonField(d, r'''$.first_name''')?.toString() ?? '';
    final last = getJsonField(d, r'''$.last_name''')?.toString() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    final n = getJsonField(d, r'''$.name''')?.toString() ?? '';
    if (n.isNotEmpty && n != 'null') return n;
    return 'Driver ${index + 1}';
  }

  String _driverVehicle(dynamic d) {
    String pick(String path) =>
        getJsonField(d, path)?.toString().trim() ?? '';
    for (final path in [
      r'''$.adminVehicle.vehicle_name''',
      r'''$.vehicle_type''',
      r'''$.vehicle_number''',
      r'''$.vehicles[0].vehicle_model''',
    ]) {
      final v = pick(path);
      if (v.isNotEmpty && v != 'null') return v;
    }
    return 'Not assigned';
  }

  Widget _buildDriverList(List<dynamic> drivers, String emptyMessage) {
    final theme = FlutterFlowTheme.of(context);
    return RefreshIndicator(
      color: theme.primary,
      onRefresh: _refreshDrivers,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (drivers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drive_eta_rounded,
                          size: 64, color: theme.alternate),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: theme.bodyLarge.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final d = drivers[index];
                    final name = _driverName(d, index);
                    final vehicle = _driverVehicle(d);
                    final mobile =
                        getJsonField(d, r'''$.mobile_number''')?.toString() ?? '';
                    final img =
                        getJsonField(d, r'''$.profile_image''')?.toString();
                    final driverId =
                        castToType<int>(getJsonField(d, r'''$.id'''));
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

                    final imageUrl = (img != null &&
                            img.isNotEmpty &&
                            img != 'null')
                        ? (img.startsWith('http')
                            ? img
                            : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}')
                        : '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: driverId == null
                                  ? null
                                  : () => context.pushNamedAuth(
                                        DriverDetailsWidget.routeName,
                                        context.mounted,
                                        queryParameters: {
                                          'driverId': driverId.toString(),
                                        },
                                      ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.secondaryBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: theme.alternate),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: 'driver_photo_${driverId ?? index}',
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.primary
                                                .withValues(alpha: 0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: SafeNetworkAvatar(
                                          imageUrl: imageUrl,
                                          radius: 28,
                                          placeholderIcon: Icons.person,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.titleMedium.override(
                                              font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.directions_car_rounded,
                                                size: 14,
                                                color: theme.secondaryText,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  vehicle,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme.bodySmall
                                                      .override(
                                                    font: GoogleFonts.inter(),
                                                    color:
                                                        theme.secondaryText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (mobile.isNotEmpty &&
                                              mobile != 'null') ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              mobile,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.bodySmall.override(
                                                font: GoogleFonts.inter(),
                                                color: theme.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: badgeColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            statusStr.toUpperCase(),
                                            style: theme.labelSmall.override(
                                              font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FontWeight.bold),
                                              color: badgeTextColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: theme.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: drivers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.goNamedAuth(DashboardScreen.routeName, context.mounted);
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
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _refreshDrivers,
                ),
              ],
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Rejected'),
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: FlutterFlowTheme.of(context).error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Could not load drivers.',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _driversFuture = GetDriversCall.call(
                                    token: currentAuthenticationToken,
                                  );
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allDrivers = _extractDrivers(response.jsonBody);

                  final pendingDrivers = allDrivers
                      .where((d) => _normalizeKycStatus(d) == 'pending')
                      .toList();
                  final approvedDrivers = allDrivers
                      .where((d) => _normalizeKycStatus(d) == 'approved')
                      .toList();
                  final rejectedDrivers = allDrivers
                      .where((d) => _normalizeKycStatus(d) == 'rejected')
                      .toList();

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