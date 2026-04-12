import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_scaffold.dart';
import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'ride_management_model.dart';
import 'ride_party_fetch.dart';
import 'ride_row_data.dart';

export 'ride_management_model.dart';

class RideManagementWidget extends StatefulWidget {
  const RideManagementWidget({super.key});

  static String routeName = 'RideManagement';
  static String routePath = '/ride-management';

  @override
  State<RideManagementWidget> createState() => _RideManagementWidgetState();
}

class _RideManagementWidgetState extends State<RideManagementWidget>
    with TickerProviderStateMixin {
  late RideManagementModel _model;
  late TabController _tabController;
  List<dynamic> _allRides = [];
  bool _isLoading = true;
  String? _error;
  Map<int, Map<String, dynamic>> _userById = {};
  Map<int, Map<String, dynamic>> _driverById = {};

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _tableMinWidth = 720;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RideManagementModel());
    _tabController = TabController(length: 4, vsync: this);
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _userById = {};
      _driverById = {};
    });
    try {
      final response =
          await GetRidesCall.call(token: currentAuthenticationToken);
      if (!response.succeeded) {
        setState(() {
          _error = 'Failed to load rides (${response.statusCode})';
          _isLoading = false;
        });
        return;
      }
      final list = GetRidesCall.data(response.jsonBody);
      setState(() {
        _allRides = list ?? [];
        _isLoading = false;
      });
      await _enrichRideParties();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _enrichRideParties() async {
    if (_allRides.isEmpty || !mounted) return;
    final token = currentAuthenticationToken ?? '';
    if (token.isEmpty) return;
    final uIds = <int>{};
    final dIds = <int>{};
    RidePartyFetch.collectIdsFromRides(_allRides, uIds, dIds);
    final users = await RidePartyFetch.fetchUsersByIds(uIds, token);
    final drivers = await RidePartyFetch.fetchDriversByIds(dIds, token);
    if (!mounted) return;
    setState(() {
      _userById = users;
      _driverById = drivers;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _ridesByStatus(String tab) {
    return _allRides.where((r) {
      final s = (r is Map ? r['ride_status'] : r.ride_status)
              ?.toString()
              .toLowerCase() ??
          '';
      switch (tab) {
        case 'running':
          return s.contains('progress') ||
              s == 'reached' ||
              s == 'driver_arrived';
        case 'completed':
          return s == 'completed';
        case 'scheduled':
          return s == 'requested' ||
              s == 'accepted' ||
              s.contains('pending');
        case 'cancelled':
          return s.contains('cancel');
        default:
          return false;
      }
    }).toList();
  }

  String _tabTitle(String status) {
    switch (status) {
      case 'running':
        return 'Running';
      case 'completed':
        return 'Completed';
      case 'scheduled':
        return 'Scheduled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminScaffold(
      title: 'Ride Management',
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primary.withValues(alpha: 0.1),
                  theme.secondaryBackground,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.primary,
              unselectedLabelColor: theme.secondaryText,
              indicatorColor: theme.primary,
              tabs: const [
                Tab(text: 'Running'),
                Tab(text: 'Completed'),
                Tab(text: 'Scheduled'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTripList(
                          _ridesByStatus('running'), 'running', theme),
                      _buildTripList(
                          _ridesByStatus('completed'), 'completed', theme),
                      _buildTripList(
                          _ridesByStatus('scheduled'), 'scheduled', theme),
                      _buildTripList(
                          _ridesByStatus('cancelled'), 'cancelled', theme),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(
    List<dynamic> rides,
    String status,
    FlutterFlowTheme theme,
  ) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: theme.bodyMedium),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _loadRides,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (rides.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRides,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.35,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_taxi_rounded,
                        size: 56, color: theme.secondaryText),
                    const SizedBox(height: 16),
                    Text(
                      'No ${_tabTitle(status).toLowerCase()} rides',
                      style:
                          theme.titleMedium.override(font: GoogleFonts.inter()),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull down to refresh.',
                      style: theme.bodySmall.override(font: GoogleFonts.inter()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final screenW = MediaQuery.sizeOf(context).width;
    final viewport = math.max(screenW - 32, 280.0);
    final contentW = viewport < _tableMinWidth ? _tableMinWidth : viewport;

    return RefreshIndicator(
      onRefresh: _loadRides,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.alternate.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_tabTitle(status)} rides',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${rides.length}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentW,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _tableHeader(theme),
                        ...List.generate(rides.length, (index) {
                          final raw = rides[index];
                          final base = RideRowData.tryParse(raw);
                          if (base == null) return const SizedBox.shrink();
                          final row = RideRowData.tryParse(
                            raw,
                            userDetail: base.riderUserId != null
                                ? _userById[base.riderUserId!]
                                : null,
                            driverDetail: base.linkedDriverId != null
                                ? _driverById[base.linkedDriverId!]
                                : null,
                          );
                          if (row == null) return const SizedBox.shrink();

                          final st = row.statusColor(theme);
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: row.rideId != null
                                  ? () => context.pushNamedAuth(
                                        RideDetailsWidget.routeName,
                                        context.mounted,
                                        queryParameters: {
                                          'rideId': row.rideId.toString(),
                                        },
                                      )
                                  : null,
                              child: _tableDataRow(theme: theme, row: row, st: st),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                duration: 280.ms,
                                delay: (index * 28).ms,
                              )
                              .slideX(
                                begin: 0.02,
                                end: 0,
                                duration: 280.ms,
                                delay: (index * 28).ms,
                                curve: Curves.easeOut,
                              );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(FlutterFlowTheme theme) {
    TextStyle hStyle() => GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.secondaryText,
          letterSpacing: 0.2,
        );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 88, child: Text('Ride ID', style: hStyle())),
          Expanded(flex: 5, child: Text('User', style: hStyle())),
          Expanded(flex: 5, child: Text('Driver', style: hStyle())),
          Expanded(flex: 6, child: Text('Pickup → Drop', style: hStyle())),
          SizedBox(width: 72, child: Text('Fare', style: hStyle())),
          SizedBox(width: 96, child: Text('Status', style: hStyle())),
          SizedBox(
            width: 48,
            child: Text('Time', textAlign: TextAlign.end, style: hStyle()),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _tableDataRow({
    required FlutterFlowTheme theme,
    required RideRowData row,
    required Color st,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.35)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              row.rideIdLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _personBlock(
              theme: theme,
              name: row.riderName,
              phone: row.riderPhone,
              imageUrl: row.riderImageUrl,
            ),
          ),
          Expanded(
            flex: 5,
            child: _personBlock(
              theme: theme,
              name: row.driverName,
              phone: row.driverPhone,
              imageUrl: row.driverImageUrl,
            ),
          ),
          Expanded(
            flex: 6,
            child: _routeBlock(theme: theme, pickup: row.pickup, drop: row.drop),
          ),
          SizedBox(
            width: 72,
            child: Text(
              row.fare,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: st.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  row.humanStatus,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: st,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              row.time24,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 22,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personBlock({
    required FlutterFlowTheme theme,
    required String name,
    required String phone,
    required String imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SafeNetworkAvatar(
          imageUrl: imageUrl,
          radius: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (phone.isNotEmpty)
                Text(
                  phone,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeBlock({
    required FlutterFlowTheme theme,
    required String pickup,
    required String drop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                pickup,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
        Text(
          drop,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: theme.secondaryText,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
