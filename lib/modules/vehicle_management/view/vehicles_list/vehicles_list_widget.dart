import '/core/auth/auth_util.dart';
import '/core/network/api_config.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import '/index.dart';
import '/core/services/cache_service.dart';
import '/core/services/cache_policy.dart';
import '/shared/widgets/skeleton_block.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '/modules/dashboard/widgets/metric_card.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vehicles_list_model.dart';
export 'vehicles_list_model.dart';

class VehiclesListWidget extends StatefulWidget {
  const VehiclesListWidget({super.key});

  static String routeName = 'VehiclesList';
  static String routePath = '/vehicles-list';

  @override
  State<VehiclesListWidget> createState() => _VehiclesListWidgetState();
}

class _VehiclesListWidgetState extends State<VehiclesListWidget> {
  static const String _cacheKey = CachePolicy.vehiclesKey;
  static const Duration _cacheTtl = CachePolicy.vehiclesTtl;
  late VehiclesListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _vehicleTypes = [];
  List<Map<String, dynamic>> _adminVehicles = [];
  bool _isLoading = true;
  bool _isBackgroundRefreshing = false;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;
  Future<void>? _inFlightLoad;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VehiclesListModel());
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _loadCachePreview();
    final age = await CacheService.getCacheAge(_cacheKey);
    final shouldRefresh = age == null ||
        age > _cacheTtl ||
        (_vehicleTypes.isEmpty && _adminVehicles.isEmpty);
    if (shouldRefresh) {
      await _loadData(backgroundRefresh: true);
    }
  }

  Future<void> _loadCachePreview() async {
    final cached = await CacheService.getData(_cacheKey);
    final ts = await CacheService.getLastUpdated(_cacheKey);
    if (!mounted || cached == null) return;
    final types = _toMapList(cached['vehicleTypes']);
    final vehicles = _toMapList(cached['adminVehicles']);
    if (types.isEmpty && vehicles.isEmpty) return;
    setState(() {
      _vehicleTypes = types;
      _adminVehicles = vehicles;
      _lastUpdatedAt = ts;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  Future<void> _loadData({bool backgroundRefresh = false}) async {
    if (_inFlightLoad != null) {
      return _inFlightLoad;
    }
    _inFlightLoad = _loadDataInternal(backgroundRefresh: backgroundRefresh);
    try {
      await _inFlightLoad;
    } finally {
      _inFlightLoad = null;
    }
  }

  Future<void> _loadDataInternal({bool backgroundRefresh = false}) async {
    final hasPreview = _vehicleTypes.isNotEmpty || _adminVehicles.isNotEmpty;
    setState(() {
      _isLoading = !hasPreview && !backgroundRefresh;
      _isBackgroundRefreshing = hasPreview || backgroundRefresh;
      _errorMessage = null;
    });
    try {
      final typesFuture = GetVehicleTypesCall.call(token: currentAuthenticationToken);
      final vehiclesFuture = GetAllVehiclesCall.call(token: currentAuthenticationToken);

      final results = await Future.wait([typesFuture, vehiclesFuture]);
      final typesResponse = results[0];
      final vehiclesResponse = results[1];

      if (!mounted) return;

      List<Map<String, dynamic>> types = [];
      if (typesResponse.succeeded) {
        dynamic raw = typesResponse.jsonBody;
        if (raw is Map) raw = getJsonField(raw, r'''$.data''');
        if (raw == null && typesResponse.jsonBody is Map) {
          raw = getJsonField(typesResponse.jsonBody, r'''$.vehicle_types''') ??
              getJsonField(typesResponse.jsonBody, r'''$.vehicleTypes''');
        }
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) types.add(Map<String, dynamic>.from(item));
          }
        }
      }

      List<Map<String, dynamic>> vehicles = [];
      if (vehiclesResponse.succeeded) {
        dynamic raw = vehiclesResponse.jsonBody;
        if (raw is Map) raw = getJsonField(raw, r'''$.data''');
        if (raw == null && vehiclesResponse.jsonBody is Map) {
          raw = getJsonField(vehiclesResponse.jsonBody, r'''$.vehicles''') ??
              getJsonField(vehiclesResponse.jsonBody, r'''$.admin_vehicles''');
        }
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) vehicles.add(Map<String, dynamic>.from(item));
          }
        }
      }

      final changed = _didVehiclesDataChange(types, vehicles);
      setState(() {
        if (changed) {
          _vehicleTypes = types;
          _adminVehicles = vehicles;
        }
        _isLoading = false;
        _isBackgroundRefreshing = false;
      });
      await CacheService.saveData(_cacheKey, {
        'vehicleTypes': types,
        'adminVehicles': vehicles,
      });
      _lastUpdatedAt = await CacheService.getLastUpdated(_cacheKey);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isBackgroundRefreshing = false;
          _errorMessage = (_vehicleTypes.isNotEmpty || _adminVehicles.isNotEmpty)
              ? 'Showing last updated data'
              : e.toString();
        });
        if (_vehicleTypes.isNotEmpty || _adminVehicles.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Showing last updated data')),
          );
        }
      }
    }
  }

  bool _didVehiclesDataChange(
    List<Map<String, dynamic>> types,
    List<Map<String, dynamic>> vehicles,
  ) {
    if (_vehicleTypes.length != types.length) return true;
    if (_adminVehicles.length != vehicles.length) return true;
    return _vehicleTypes.toString() != types.toString() ||
        _adminVehicles.toString() != vehicles.toString();
  }

  List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Get sub vehicles where vehicle_type_id matches the given type id
  List<Map<String, dynamic>> _getVehiclesForType(dynamic typeId) {
    if (typeId == null) return [];
    final id = typeId is int ? typeId : int.tryParse(typeId.toString());
    if (id == null) return [];
    return _adminVehicles.where((v) {
      final vid = getJsonField(v, r'''$.vehicle_type_id''') ??
          getJsonField(v, r'''$.vehicleTypeId''');
      if (vid == null) return false;
      final vIdInt = vid is int ? vid : int.tryParse(vid.toString());
      return vIdInt == id;
    }).toList();
  }

  /// Sub vehicles whose vehicle_type_id is not in the types list
  List<Map<String, dynamic>> _getOrphanVehicles() {
    final typeIds = _vehicleTypes.map((t) {
      final id = getJsonField(t, r'''$.id''') ?? getJsonField(t, r'''$._id''');
      return id is int ? id : int.tryParse(id.toString());
    }).whereType<int>().toSet();
    return _adminVehicles.where((v) {
      final vid = getJsonField(v, r'''$.vehicle_type_id''') ??
          getJsonField(v, r'''$.vehicleTypeId''');
      if (vid == null) return true;
      final vIdInt = vid is int ? vid : int.tryParse(vid.toString());
      return vIdInt == null || !typeIds.contains(vIdInt);
    }).toList();
  }

  bool get _hasOrphans => _getOrphanVehicles().isNotEmpty;

  int get _orphanCount => _getOrphanVehicles().length;

  Widget _buildDashboardHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final orphans = _orphanCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isBackgroundRefreshing)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${_vehicleTypes.length} types · ${_adminVehicles.length} vehicles',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.secondaryText,
                ),
              ),
            ),
            if (_lastUpdatedAt != null)
              Text(
                'Updated ${dateTimeFormat('relative', _lastUpdatedAt)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.secondaryText,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              title: 'Vehicle types',
              value: '${_vehicleTypes.length}',
              icon: Icons.category_outlined,
              accentColor: DashboardTokens.metricUsersAccent,
              onTap: () => context.pushNamedAuth(
                AddVehicleTypeWidget.routeName,
                context.mounted,
              ),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'Fleet size',
              value: '${_adminVehicles.length}',
              icon: Icons.directions_car_rounded,
              accentColor: DashboardTokens.metricDriversAccent,
              onTap: () => context.pushNamedAuth(
                AddVehicleWidget.routeName,
                context.mounted,
              ),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: orphans > 0 ? 'Needs review' : 'Unassigned',
              value: orphans > 0 ? '$orphans' : '—',
              subtitle: orphans > 0 ? 'Untyped' : 'All grouped',
              icon: orphans > 0
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              accentColor: orphans > 0
                  ? DashboardTokens.metricEarningsAccent
                  : DashboardTokens.metricWalletAccent,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Fleet by type',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// White rounded surface matching dashboard cards.
  /// White rounded surface with a colored left border accent.
  BoxDecoration _fleetCardDecoration({Color? accentColor}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
      border: Border(
        left: BorderSide(
          color: accentColor ?? DashboardTokens.primaryOrange,
          width: 4,
        ),
      ),
      boxShadow: DashboardTokens.softShadow,
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
            boxShadow: DashboardTokens.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  List<Map<String, dynamic>> _getVehiclesFromNested(Map<String, dynamic> type) {
    final nested = getJsonField(type, r'''$.vehicles''') ??
        getJsonField(type, r'''$.admin_vehicles''') ??
        getJsonField(type, r'''$.vehiclesList''') ??
        getJsonField(type, r'''$.sub_vehicles''');
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DashboardTokens.pageBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: DashboardTokens.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'VEHICLES',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Add vehicle',
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 26),
              onPressed: () =>
                  context.pushNamedAuth(AddVehicleWidget.routeName, context.mounted),
            ),
            IconButton(
              tooltip: 'Add vehicle type',
              icon: const Icon(Icons.category_outlined, color: Colors.white, size: 24),
              onPressed: () => context.pushNamedAuth(
                AddVehicleTypeWidget.routeName,
                context.mounted,
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
              onPressed: (_isLoading || _isBackgroundRefreshing)
                  ? null
                  : () => _loadData(backgroundRefresh: true),
            ),
          ],
        ),
        body: _isLoading
            ? ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      3,
                      (_) => const SkeletonBlock(
                        width: 108,
                        height: 96,
                        radius: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SkeletonBlock(
                    width: double.infinity,
                    height: 120,
                    radius: 14,
                  ),
                  const SizedBox(height: 12),
                  const SkeletonBlock(
                    width: double.infinity,
                    height: 120,
                    radius: 14,
                  ),
                ],
              )
            : _errorMessage != null &&
                    _vehicleTypes.isEmpty &&
                    _adminVehicles.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(DashboardTokens.cardRadius),
                          boxShadow: DashboardTokens.cardShadow,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: FlutterFlowTheme.of(context).error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load: $_errorMessage',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FFButtonWidget(
                              onPressed: _loadData,
                              text: 'Retry',
                              options: FFButtonOptions(
                                color: DashboardTokens.primaryOrange,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: DashboardTokens.primaryOrange,
                    onRefresh: () => _loadData(backgroundRefresh: true),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _buildDashboardHeader(context),
                        if (_vehicleTypes.isEmpty && _adminVehicles.isEmpty)
                          _buildEmptyFleetPlaceholder(context)
                        else if (_vehicleTypes.isEmpty)
                          _buildUnassignedVehiclesSection()
                        else ...[
                          for (final type in _vehicleTypes)
                            _buildVehicleTypeSection(type),
                          if (_hasOrphans) _buildOrphanVehiclesSection(),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyFleetPlaceholder(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      decoration: _fleetCardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 56,
            color: theme.secondaryText.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicles yet',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create vehicle types and sub-types to build your fleet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.35,
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          FFButtonWidget(
            onPressed: () =>
                context.pushNamedAuth(AddVehicleWidget.routeName, context.mounted),
            text: 'Add vehicle',
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            options: FFButtonOptions(
              color: DashboardTokens.primaryOrange,
              textStyle: theme.titleSmall.override(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeSection(Map<String, dynamic> type) {
    final typeId = getJsonField(type, r'''$.id''') ?? getJsonField(type, r'''$._id''');
    final typeName = getJsonField(type, r'''$.name''')?.toString() ?? 'Unknown';
    final imgPath = getJsonField(type, r'''$.image''')?.toString();
    final imgUrl = imgPath != null && imgPath.isNotEmpty
        ? (imgPath.startsWith('http') ? imgPath : '${ApiConfig.baseUrl}$imgPath')
        : null;

    var subVehicles = _getVehiclesFromNested(type);
    if (subVehicles.isEmpty) {
      subVehicles = _getVehiclesForType(typeId);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _fleetCardDecoration(accentColor: DashboardTokens.primaryOrange),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.white,
        child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: imgUrl != null && imgUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imgUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.directions_car,
                    color: DashboardTokens.primaryOrange,
                    size: 40,
                  ),
                ),
              )
            : Icon(
                Icons.directions_car,
                color: DashboardTokens.primaryOrange,
                size: 40,
              ),
        title: Text(
          typeName,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        subtitle: Text(
          '${subVehicles.length} sub vehicle${subVehicles.length == 1 ? '' : 's'}',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        iconColor: DashboardTokens.primaryOrange,
        collapsedIconColor: DashboardTokens.primaryOrange,
        children: [
          if (subVehicles.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No sub vehicles yet',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            )
          else
            ...subVehicles.map((v) => _buildSubVehicleTile(v)),
          if (subVehicles.isNotEmpty) ...[
            const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: DashboardTokens.metricOnlineAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pricing',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            ...subVehicles.map((v) => _buildPricingTile(v)),
            const SizedBox(height: 8),
          ],
        ],
        ),
      ),
    );
  }

  String _rideCategoryDisplay(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    return val == 1 ? 'Pro' : 'Normal';
  }

  Widget _buildSubVehicleTile(Map<String, dynamic> vehicle) {
    final name = getJsonField(vehicle, r'''$.vehicle_name''') ??
        getJsonField(vehicle, r'''$.name''') ??
        getJsonField(vehicle, r'''$.vehicleName''') ??
        'Unknown';
    final rideCategory = getJsonField(vehicle, r'''$.ride_category''') ??
        getJsonField(vehicle, r'''$.rideCategory''');
    final seating = getJsonField(vehicle, r'''$.seating_capacity''') ??
        getJsonField(vehicle, r'''$.seatingCapacity''');
    final luggage = getJsonField(vehicle, r'''$.luggage_capacity''') ??
        getJsonField(vehicle, r'''$.luggageCapacity''');
    // Prefer vehicle_image_url (full URL from API); fallback to vehicle_image
    final imgUrlRaw = getJsonField(vehicle, r'''$.vehicle_image_url''') ??
        getJsonField(vehicle, r'''$.vehicleImageUrl''');
    final imgPath = imgUrlRaw ?? getJsonField(vehicle, r'''$.vehicle_image''') ??
        getJsonField(vehicle, r'''$.image''') ??
        getJsonField(vehicle, r'''$.vehicleImage''');
    final imgUrl = imgPath != null && imgPath.toString().isNotEmpty
        ? (imgPath.toString().startsWith('http')
            ? imgPath.toString()
            : '${ApiConfig.baseUrl}/${imgPath.toString().replaceFirst(RegExp(r'^/'), '')}')
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: DashboardTokens.metricDriversBg,
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: imgUrl != null && imgUrl.isNotEmpty
                ? Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.directions_car_outlined,
                      color: DashboardTokens.metricDriversAccent,
                      size: 22,
                    ),
                  )
                : Icon(
                    Icons.directions_car_outlined,
                    color: DashboardTokens.metricDriversAccent,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toString(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (rideCategory != null ||
                    seating != null ||
                    luggage != null) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (rideCategory != null)
                        _buildChip(
                          _rideCategoryDisplay(rideCategory),
                          DashboardTokens.metricUsersAccent,
                        ),
                      if (seating != null)
                        _buildChip(
                          '$seating seats',
                          DashboardTokens.metricDriversAccent,
                        ),
                      if (luggage != null)
                        _buildChip(
                          '$luggage luggage',
                          DashboardTokens.metricRidesAccent,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTile(Map<String, dynamic> vehicle) {
    final name = getJsonField(vehicle, r'''$.vehicle_name''') ??
        getJsonField(vehicle, r'''$.name''') ??
        getJsonField(vehicle, r'''$.vehicleName''') ??
        'Vehicle';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: DashboardTokens.metricOnlineBg,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: DashboardTokens.metricOnlineAccent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.payments_outlined,
              color: DashboardTokens.metricOnlineAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name.toString(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _openPricingDialog(vehicle),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: DashboardTokens.primaryOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Set Pricing',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPricingDialog(Map<String, dynamic> vehicle) async {
    final rawId = getJsonField(vehicle, r'''$.id''') ??
        getJsonField(vehicle, r'''$.vehicle_id''') ??
        getJsonField(vehicle, r'''$.vehicleId''');
    final vehicleId = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (vehicleId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vehicle ID missing.'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
      return;
    }

    final result = await showDialog<_PricingFormData>(
      context: context,
      builder: (ctx) => const _SetPricingDialog(),
    );
    if (result == null) return;

    final response = await SetPricingCall.call(
      token: currentAuthenticationToken,
      vehicleId: vehicleId,
      baseKmStart: result.baseKmStart,
      baseKmEnd: result.baseKmEnd,
      baseFare: result.baseFare,
      pricePerKm: result.pricePerKm,
    );

    if (!mounted) return;
    if (response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pricing updated successfully'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set pricing (${response.statusCode})'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Widget _buildOrphanVehiclesSection() {
    final orphans = _getOrphanVehicles();
    if (orphans.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _fleetCardDecoration(accentColor: DashboardTokens.metricEarningsAccent),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.white,
        child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          Icons.directions_car_outlined,
          color: DashboardTokens.metricEarningsAccent,
          size: 40,
        ),
        title: Text(
          'Other Vehicles',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Text(
          '${orphans.length} vehicle${orphans.length == 1 ? '' : 's'} (type unknown)',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        iconColor: DashboardTokens.metricEarningsAccent,
        collapsedIconColor: DashboardTokens.metricEarningsAccent,
        children: orphans.map((v) => _buildSubVehicleTile(v)).toList(),
        ),
      ),
    );
  }

  Widget _buildUnassignedVehiclesSection() {
    if (_adminVehicles.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _fleetCardDecoration(accentColor: DashboardTokens.metricUsersAccent),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.white,
        child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          Icons.directions_car,
          color: DashboardTokens.metricUsersAccent,
          size: 40,
        ),
        title: Text(
          'All Vehicles',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Text(
          '${_adminVehicles.length} vehicle${_adminVehicles.length == 1 ? '' : 's'}',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        iconColor: DashboardTokens.metricUsersAccent,
        collapsedIconColor: DashboardTokens.metricUsersAccent,
        children: _adminVehicles.map((v) => _buildSubVehicleTile(v)).toList(),
        ),
      ),
    );
  }
}

class _PricingFormData {
  _PricingFormData({
    required this.baseKmStart,
    required this.baseKmEnd,
    required this.baseFare,
    required this.pricePerKm,
  });

  final int baseKmStart;
  final int baseKmEnd;
  final num baseFare;
  final num pricePerKm;
}

class _SetPricingDialog extends StatefulWidget {
  const _SetPricingDialog();

  @override
  State<_SetPricingDialog> createState() => _SetPricingDialogState();
}

class _SetPricingDialogState extends State<_SetPricingDialog> {
  late TextEditingController _baseKmStartController;
  late TextEditingController _baseKmEndController;
  late TextEditingController _baseFareController;
  late TextEditingController _pricePerKmController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _baseKmStartController = TextEditingController();
    _baseKmEndController = TextEditingController();
    _baseFareController = TextEditingController();
    _pricePerKmController = TextEditingController();
  }

  @override
  void dispose() {
    _baseKmStartController.dispose();
    _baseKmEndController.dispose();
    _baseFareController.dispose();
    _pricePerKmController.dispose();
    super.dispose();
  }

  void _submit() {
    final baseKmStart = int.tryParse(_baseKmStartController.text.trim());
    final baseKmEnd = int.tryParse(_baseKmEndController.text.trim());
    final baseFare = num.tryParse(_baseFareController.text.trim());
    final pricePerKm = num.tryParse(_pricePerKmController.text.trim());

    if (baseKmStart == null ||
        baseKmEnd == null ||
        baseFare == null ||
        pricePerKm == null) {
      setState(() {
        _errorText = 'Please enter valid numbers in all fields.';
      });
      return;
    }

    Navigator.pop(
      context,
      _PricingFormData(
        baseKmStart: baseKmStart,
        baseKmEnd: baseKmEnd,
        baseFare: baseFare,
        pricePerKm: pricePerKm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Pricing'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _baseKmStartController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base KM Start',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _baseKmEndController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base KM End',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _baseFareController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Base Fare',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pricePerKmController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price per KM',
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        color: FlutterFlowTheme.of(context).error,
                        font: GoogleFonts.inter(),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: Colors.white,
            textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  color: Colors.white,
                  font: GoogleFonts.inter(),
                  fontWeight: FontWeight.w600,
                ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
