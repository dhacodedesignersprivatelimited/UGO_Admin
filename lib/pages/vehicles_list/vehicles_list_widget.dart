import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
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
  late VehiclesListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _vehicleTypes = [];
  List<Map<String, dynamic>> _adminVehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VehiclesListModel());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
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

      setState(() {
        _vehicleTypes = types;
        _adminVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
        }
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
            onPressed: () =>
                context.goNamedAuth(DashboardPageWidget.routeName, context.mounted),
          ),
          title: Text(
            'Vehicles',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
              onPressed: () => context.pushNamedAuth(AddVehicleWidget.routeName, context.mounted),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 26),
              onPressed: _isLoading ? null : _loadData,
            ),
          ],
          elevation: 2,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                FlutterFlowTheme.of(context).secondaryBackground,
              ],
            ),
          ),
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading vehicles...',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: FlutterFlowTheme.of(context).error),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load: $_errorMessage',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            FFButtonWidget(
                              onPressed: _loadData,
                              text: 'Retry',
                              options: FFButtonOptions(
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: _vehicleTypes.isEmpty && _adminVehicles.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_car_outlined,
                                          size: 80,
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No vehicles yet',
                                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add vehicle types and sub types to get started',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                        ),
                                        const SizedBox(height: 24),
                                        FFButtonWidget(
                                          onPressed: () => context.pushNamedAuth(AddVehicleWidget.routeName, context.mounted),
                                          text: 'Add Vehicle',
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          options: FFButtonOptions(
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _vehicleTypes.isEmpty
                                  ? 1
                                  : _vehicleTypes.length + (_hasOrphans ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_vehicleTypes.isEmpty) {
                                  return _buildUnassignedVehiclesSection();
                                }
                                if (index >= _vehicleTypes.length) {
                                  return _buildOrphanVehiclesSection();
                                }
                                final type = _vehicleTypes[index];
                                return _buildVehicleTypeSection(type);
                              },
                            ),
                    ),
        ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: FlutterFlowTheme.of(context).primary,
                    size: 40,
                  ),
                ),
              )
            : Icon(
                Icons.directions_car,
                color: FlutterFlowTheme.of(context).primary,
                size: 40,
              ),
        title: Text(
          typeName,
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              ),
        ),
        subtitle: Text(
          '${subVehicles.length} sub vehicle${subVehicles.length == 1 ? '' : 's'}',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
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
        ],
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

    return ListTile(
      leading: imgUrl != null && imgUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imgUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car_outlined,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
            )
          : Icon(
              Icons.directions_car_outlined,
              color: FlutterFlowTheme.of(context).primary,
            ),
      title: Text(
        name.toString(),
        style: FlutterFlowTheme.of(context).titleMedium,
      ),
      subtitle: Text(
        [
          if (rideCategory != null) _rideCategoryDisplay(rideCategory),
          if (seating != null) 'Seats: $seating',
          if (luggage != null) 'Luggage: $luggage',
        ].where((x) => x.isNotEmpty).join(' • '),
        style: FlutterFlowTheme.of(context).bodySmall.override(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
      ),
    );
  }

  Widget _buildOrphanVehiclesSection() {
    final orphans = _getOrphanVehicles();
    if (orphans.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          Icons.directions_car_outlined,
          color: FlutterFlowTheme.of(context).primary,
          size: 40,
        ),
        title: Text(
          'Other Vehicles',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              ),
        ),
        subtitle: Text(
          '${orphans.length} vehicle${orphans.length == 1 ? '' : 's'} (type unknown)',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
        children: orphans.map((v) => _buildSubVehicleTile(v)).toList(),
      ),
    );
  }

  Widget _buildUnassignedVehiclesSection() {
    if (_adminVehicles.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          Icons.directions_car,
          color: FlutterFlowTheme.of(context).primary,
          size: 40,
        ),
        title: Text(
          'All Vehicles',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              ),
        ),
        subtitle: Text(
          '${_adminVehicles.length} vehicle${_adminVehicles.length == 1 ? '' : 's'}',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
        children: _adminVehicles.map((v) => _buildSubVehicleTile(v)).toList(),
      ),
    );
  }
}
