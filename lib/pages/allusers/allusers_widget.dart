import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'allusers_model.dart';
export 'allusers_model.dart';

class AllusersWidget extends StatefulWidget {
  const AllusersWidget({super.key});

  static String routeName = 'Allusers';
  static String routePath = '/allusers';

  @override
  State<AllusersWidget> createState() => _AllusersWidgetState();
}

class _AllusersWidgetState extends State<AllusersWidget>
    with TickerProviderStateMixin {
  late AllusersModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _mainTabController;
  late Future<ApiCallResponse> _driversFuture;
  late Future<List<dynamic>> _allKycPendingFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllusersModel());
    _mainTabController = TabController(length: 2, vsync: this);
    _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
    _allKycPendingFuture = _fetchAllKycPending();
  }

  /// Fetches all pending KYC drivers across all pages (no page limit)
  Future<List<dynamic>> _fetchAllKycPending() async {
    final allDrivers = <dynamic>[];
    int page = 1;
    const limit = 100;
    int total = limit + 1;

    while (allDrivers.length < total) {
      final response = await KycPendingCall.call(
        token: currentAuthenticationToken,
        page: page,
        limit: limit,
      );
      if (!response.succeeded) break;

      final data = getJsonField(response.jsonBody, r'''$.data''');
      total = castToType<int>(getJsonField(data, r'''$.total''')) ?? 0;
      final drivers = (getJsonField(data, r'''$.drivers''') as List?)?.toList() ?? [];
      allDrivers.addAll(drivers);
      if (drivers.length < limit || allDrivers.length >= total) break;
      page++;
    }

    if (mounted) {
      _model.pendingKycDrivers = allDrivers;
      _model.pendingKycDriverIds = allDrivers
          .map((d) => castToType<int>(getJsonField(d, r'''$.driver_id''')))
          .whereType<int>()
          .toList();
    }
    return allDrivers;
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _model.dispose();
    super.dispose();
  }

  // --- Drivers tab: build driver list (same as drivers_widget) ---
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

        final statusStr = (getJsonField(d, r'''$.verification_status''')
                    ?.toString() ??
                'pending')
            .toLowerCase();

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
              onTap: () => context.pushNamedAuth(
                DriverLicenseWidget.routeName,
                context.mounted,
                queryParameters: {'userId': firstName},
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.1),
                      backgroundImage: img != null &&
                              img.isNotEmpty &&
                              img != 'null'
                          ? NetworkImage(img.startsWith('http')
                              ? img
                              : '${ApiConfig.baseUrl}$img')
                          : null,
                      child: img == null || img.isEmpty || img == 'null'
                          ? Icon(
                              Icons.person,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style:
                                FlutterFlowTheme.of(context).titleMedium.override(
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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

  // --- Users tab: build user list ---
  Widget _buildUserList(List<dynamic> users) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: FlutterFlowTheme.of(context).alternate,
              ),
              const SizedBox(height: 16),
              Text(
                'No users yet',
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
      itemCount: users.length,
      itemBuilder: (context, index) {
        final u = users[index];
        final name = getJsonField(u, r'''$.name''')?.toString() ??
            '${getJsonField(u, r'''$.first_name''') ?? ''} ${getJsonField(u, r'''$.last_name''') ?? ''}'
                .trim() ??
            'User ${getJsonField(u, r'''$.user_id''') ?? index + 1}';
        final mobile =
            getJsonField(u, r'''$.mobile_number''')?.toString() ?? '';
        final email = getJsonField(u, r'''$.email''')?.toString() ?? '';
        final img = getJsonField(u, r'''$.profile_image''')?.toString();
        final imgUrl = img != null && img.isNotEmpty && img != 'null'
            ? (img.startsWith('http') ? img : '${ApiConfig.baseUrl}$img')
            : null;

        final userId = castToType<int>(getJsonField(u, r'''$.id''') ??
            getJsonField(u, r'''$.user_id'''));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: userId != null
                  ? () => context.pushNamedAuth(
                        UserDetailsWidget.routeName,
                        context.mounted,
                        queryParameters: {'userId': userId.toString()},
                      )
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                  leading: CircleAvatar(
                radius: 26,
                backgroundColor:
                    FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                backgroundImage:
                    imgUrl != null ? NetworkImage(imgUrl) : null,
                child: imgUrl == null
                    ? Icon(
                        Icons.person,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 26,
                      )
                    : null,
              ),
              title: Text(
                name,
                style:
                    FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
              ),
              subtitle: Text(
                mobile.isNotEmpty ? mobile : (email.isNotEmpty ? email : '—'),
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: FlutterFlowTheme.of(context).primary,
              ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
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
              onPressed: () => context.goNamedAuth(
                  DashboardPageWidget.routeName, context.mounted),
            ),
            title: Text(
              'Users & Drivers',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: Colors.white,
                    fontSize: 22,
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_rounded,
                    color: Colors.white, size: 24),
                tooltip: 'Add User',
                onPressed: () => context.pushNamedAuth(
                    AddUserWidget.routeName, context.mounted),
              ),
              IconButton(
                icon: const Icon(Icons.drive_eta_rounded,
                    color: Colors.white, size: 24),
                tooltip: 'Add Driver',
                onPressed: () => context.pushNamedAuth(
                    AddDriverWidget.routeName, context.mounted),
              ),
            ],
            bottom: TabBar(
              controller: _mainTabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.drive_eta_rounded, size: 22),
                  text: 'Drivers',
                ),
                Tab(
                  icon: Icon(Icons.people_rounded, size: 22),
                  text: 'Users',
                ),
              ],
            ),
            elevation: 2,
          ),
          body: TabBarView(
            controller: _mainTabController,
            children: [
              _buildDriversTab(),
              _buildUsersTab(),
            ],
          ),
        ),
      ),
    );
  }

  List<dynamic> _transformKycDriversToDriverFormat(List<dynamic> kycDrivers) {
    return kycDrivers.map((d) {
      final driverId = castToType<int>(getJsonField(d, r'''$.driver_id'''));
      final name = getJsonField(d, r'''$.name''')?.toString() ?? '';
      return {
        'id': driverId,
        'first_name': name,
        'last_name': '',
        'profile_image': null,
        'verification_status': 'pending',
      };
    }).toList();
  }

  Widget _buildDriversTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FlutterFlowTheme.of(context).primary.withOpacity(0.05),
            FlutterFlowTheme.of(context).secondaryBackground,
          ],
        ),
      ),
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _driversFuture,
          _allKycPendingFuture,
        ]),
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

          final results = snapshot.data!;
          final driversResponse = results[0] as ApiCallResponse;
          final kycList = results[1] as List<dynamic>;
          final pendingDrivers = _transformKycDriversToDriverFormat(kycList);

          List<dynamic> approvedDrivers = [];
          List<dynamic> rejectedDrivers = [];
          if (driversResponse.succeeded) {
            final allDrivers =
                GetDriversCall.data(driversResponse.jsonBody)?.toList() ?? [];
            approvedDrivers = allDrivers.where((d) {
              final status = (getJsonField(d, r'''$.verification_status''')
                          ?.toString() ??
                      'pending')
                  .toLowerCase();
              return status == 'approved';
            }).toList();
            rejectedDrivers = allDrivers.where((d) {
              final status = (getJsonField(d, r'''$.verification_status''')
                          ?.toString() ??
                      'pending')
                  .toLowerCase();
              return status == 'rejected';
            }).toList();
          }

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
                                      .withOpacity(0.2),
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
                      Tab(text: 'Approved'),
                      Tab(text: 'Rejected'),
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
    );
  }

  Widget _buildUsersTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FlutterFlowTheme.of(context).primary.withOpacity(0.05),
            FlutterFlowTheme.of(context).secondaryBackground,
          ],
        ),
      ),
      child: FutureBuilder<ApiCallResponse>(
        future: AllUsersCall.call(token: currentAuthenticationToken),
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
                    'Loading users...',
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
                        size: 48, color: FlutterFlowTheme.of(context).error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load users',
                      style: FlutterFlowTheme.of(context).bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          final users = AllUsersCall.usersdata(response.jsonBody)?.toList() ?? [];
          return _buildUserList(users);
        },
      ),
    );
  }
}
