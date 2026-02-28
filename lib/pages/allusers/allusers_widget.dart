import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  late Future<ApiCallResponse> _usersFuture;
  final Set<int> _updatingActiveIds = {};

  // Search Functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllusersModel());
    _mainTabController = TabController(length: 2, vsync: this);
    _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
    _usersFuture = AllUsersCall.call(token: currentAuthenticationToken);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _refreshDrivers() async {
    final future = GetDriversCall.call(token: currentAuthenticationToken);
    setState(() => _driversFuture = future);
    final response = await future;
    if (!response.succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh drivers')),
      );
    }
  }

  Future<void> _refreshUsers() async {
    final future = AllUsersCall.call(token: currentAuthenticationToken);
    setState(() => _usersFuture = future);
    final response = await future;
    if (!response.succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh users')),
      );
    }
  }

  List<dynamic> _extractDrivers(dynamic jsonBody) {
    final direct = GetDriversCall.data(jsonBody);
    if (direct is List) return direct;
    final data = getJsonField(jsonBody, r'''$.data.drivers''');
    if (data is List) return data;
    final alt = getJsonField(jsonBody, r'''$.drivers''');
    if (alt is List) return alt;
    return [];
  }

  List<dynamic> _extractUsers(dynamic jsonBody) {
    final direct = AllUsersCall.usersdata(jsonBody);
    if (direct is List) return direct;
    final data = getJsonField(jsonBody, r'''$.data.users''');
    if (data is List) return data;
    final alt = getJsonField(jsonBody, r'''$.users''');
    if (alt is List) return alt;
    return [];
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  Future<void> _updateActiveStatus(int driverId, bool nextValue) async {
    if (_updatingActiveIds.contains(driverId)) return;
    setState(() => _updatingActiveIds.add(driverId));
    final response = await UpdateDriverCall.call(
      id: driverId,
      token: currentAuthenticationToken,
      isActive: nextValue,
    );
    if (!mounted) return;
    setState(() => _updatingActiveIds.remove(driverId));
    if (response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Active status updated')),
      );
      await _refreshDrivers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update active status')),
      );
    }
  }

  String _driverName(dynamic d, int index) {
    final first = getJsonField(d, r'''$.first_name''')?.toString() ?? '';
    final last = getJsonField(d, r'''$.last_name''')?.toString() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    return getJsonField(d, r'''$.name''')?.toString() ?? 'Driver ${index + 1}';
  }

  String _userName(dynamic u, int index) {
    final name = getJsonField(u, r'''$.name''')?.toString() ?? '';
    if (name.isNotEmpty) return name;
    final first = getJsonField(u, r'''$.first_name''')?.toString() ?? '';
    final last = getJsonField(u, r'''$.last_name''')?.toString() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    return 'User ${index + 1}';
  }

  String _formatJoined(dynamic value) {
    if (value == null) return '—';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return dateTimeFormat('yMMMd', parsed);
  }

  // Local Search Filter
  List<dynamic> _filterList(List<dynamic> items, bool isDriver) {
    if (_searchQuery.isEmpty) return items;
    return items.where((item) {
      final name = isDriver ? _driverName(item, 0).toLowerCase() : _userName(item, 0).toLowerCase();
      final phone = getJsonField(item, r'''$.mobile_number''')?.toString() ?? getJsonField(item, r'''$.phone''')?.toString() ?? '';
      final email = getJsonField(item, r'''$.email''')?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery) || phone.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();
  }

  // --- UI Helpers ---

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? const Color(0xFF2E7D32) : FlutterFlowTheme.of(context).error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: FlutterFlowTheme.of(context).labelSmall.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: FlutterFlowTheme.of(context).primary),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search filters',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- Drivers tab: build driver list ---
  Widget _buildDriverList(List<dynamic> rawDrivers) {
    final drivers = _filterList(rawDrivers, true);

    if (drivers.isEmpty) {
      return _buildEmptyState(Icons.drive_eta_rounded, 'No drivers found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 100),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final d = drivers[index];
        final name = _driverName(d, index);
        final phone = getJsonField(d, r'''$.mobile_number''')?.toString() ?? getJsonField(d, r'''$.phone''')?.toString() ?? '';
        final vehicle = getJsonField(d, r'''$.adminVehicle.vehicle_name''')?.toString() ??
            getJsonField(d, r'''$.vehicle_number''')?.toString() ?? 'No Vehicle Assigned';
        final img = getJsonField(d, r'''$.profile_image''')?.toString();
        final driverId = castToType<int>(getJsonField(d, r'''$.id'''));
        final activeDriver = _parseBool(getJsonField(d, r'''$.is_active''') ?? getJsonField(d, r'''$.active_driver'''));
        final isOnline = _parseBool(getJsonField(d, r'''$.is_online'''));

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: driverId == null ? null : () => context.pushNamedAuth(
                DriverDetailsWidget.routeName,
                context.mounted,
                queryParameters: {'driverId': driverId.toString()},
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Area
                    Stack(
                      children: [
                        Hero(
                          tag: 'driver_photo_${driverId ?? index}',
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                            backgroundImage: img != null && img.isNotEmpty && img != 'null'
                                ? NetworkImage(img.startsWith('http') ? img : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}')
                                : null,
                            child: img == null || img.isEmpty || img == 'null'
                                ? Icon(Icons.person, color: FlutterFlowTheme.of(context).primary, size: 32)
                                : null,
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Info Area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusBadge(activeDriver),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.phone_iphone_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                              const SizedBox(width: 4),
                              Text(
                                phone.isNotEmpty ? phone : 'No Phone',
                                style: FlutterFlowTheme.of(context).bodySmall.override(color: FlutterFlowTheme.of(context).secondaryText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.directions_car_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vehicle,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(color: FlutterFlowTheme.of(context).secondaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Actions Area
                    Column(
                      children: [
                        Switch.adaptive(
                          value: activeDriver,
                          activeColor: const Color(0xFF2E7D32),
                          onChanged: driverId == null || _updatingActiveIds.contains(driverId)
                              ? null
                              : (val) => _updateActiveStatus(driverId, val),
                        ),
                        if (_updatingActiveIds.contains(driverId))
                          const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  // --- Users tab: build user list ---
  Widget _buildUserList(List<dynamic> rawUsers) {
    final users = _filterList(rawUsers, false);

    if (users.isEmpty) {
      return _buildEmptyState(Icons.people_outline_rounded, 'No users found');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 100),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final u = users[index];
        final name = _userName(u, index);
        final phone = getJsonField(u, r'''$.mobile_number''')?.toString() ?? getJsonField(u, r'''$.phone''')?.toString() ?? '';
        final email = getJsonField(u, r'''$.email''')?.toString() ?? '';
        final createdAt = _formatJoined(getJsonField(u, r'''$.created_at''') ?? getJsonField(u, r'''$.createdAt'''));
        final img = getJsonField(u, r'''$.profile_image''')?.toString();
        final imgUrl = img != null && img.isNotEmpty && img != 'null' ? (img.startsWith('http') ? img : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}') : null;
        final userId = castToType<int>(getJsonField(u, r'''$.id''') ?? getJsonField(u, r'''$.user_id'''));

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: userId == null ? null : () => context.pushNamedAuth(
                UserDetailsWidget.routeName,
                context.mounted,
                queryParameters: {'userId': userId.toString()},
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                      backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
                      child: imgUrl == null
                          ? Icon(Icons.person, color: FlutterFlowTheme.of(context).primary, size: 28)
                          : null,
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.phone_iphone_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                              const SizedBox(width: 4),
                              Text(phone.isNotEmpty ? phone : 'No Phone', style: FlutterFlowTheme.of(context).bodySmall),
                            ],
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.email_outlined, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: FlutterFlowTheme.of(context).bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Joined',
                            style: FlutterFlowTheme.of(context).labelSmall,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          createdAt,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
        ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).slideY(begin: 0.1, end: 0);
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
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: () => context.goNamedAuth(DashboardPageWidget.routeName, context.mounted),
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
                icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                tooltip: 'Add User',
                onPressed: () => context.pushNamedAuth(AddUserWidget.routeName, context.mounted),
              ),
              IconButton(
                icon: const Icon(Icons.drive_eta_rounded, color: Colors.white, size: 24),
                tooltip: 'Add Driver',
                onPressed: () => context.pushNamedAuth(AddDriverWidget.routeName, context.mounted),
              ),
            ],
            bottom: TabBar(
              controller: _mainTabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drive_eta_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Drivers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Users', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Search Bar Area

              Container(
                color: FlutterFlowTheme.of(context).primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, phone, or email...',
                      hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(color: Colors.black87),
                  ),
                ),
              ),
              // Tab Content Area
              Expanded(
                child: TabBarView(
                  controller: _mainTabController,
                  children: [
                    _buildDriversTab(),
                    _buildUsersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriversTab() {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
      ),
      child: FutureBuilder<ApiCallResponse>(
        future: _driversFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final response = snapshot.data!;
          if (!response.succeeded) {
            return _buildEmptyState(Icons.error_outline_rounded, 'Failed to load drivers.\nPull to refresh.');
          }

          final drivers = _extractDrivers(response.jsonBody);
          return RefreshIndicator(
            onRefresh: _refreshDrivers,
            color: FlutterFlowTheme.of(context).primary,
            child: _buildDriverList(drivers),
          );
        },
      ),
    );
  }

  Widget _buildUsersTab() {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
      ),
      child: FutureBuilder<ApiCallResponse>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final response = snapshot.data!;
          if (!response.succeeded) {
            return _buildEmptyState(Icons.error_outline_rounded, 'Failed to load users.\nPull to refresh.');
          }

          final users = _extractUsers(response.jsonBody);
          return RefreshIndicator(
            onRefresh: _refreshUsers,
            color: FlutterFlowTheme.of(context).primary,
            child: _buildUserList(users),
          );
        },
      ),
    );
  }
}