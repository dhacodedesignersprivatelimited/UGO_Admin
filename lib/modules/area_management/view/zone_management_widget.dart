import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/shared/widgets/common/metric_card.dart';
import '/shared/widgets/responsive_body.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'zone_management_model.dart';
export 'zone_management_model.dart';

class ZoneManagementWidget extends StatefulWidget {
  const ZoneManagementWidget({super.key});

  static String routeName = 'ZoneManagement';
  static String routePath = '/zone-management';

  @override
  State<ZoneManagementWidget> createState() => _ZoneManagementWidgetState();
}

class _ZoneManagementWidgetState extends State<ZoneManagementWidget> {
  late ZoneManagementModel _model;

  List<dynamic> _cities = [];
  List<dynamic> _zones = [];
  bool _loadingCities = true;
  bool _loadingZones = true;
  String? _errorCities;
  String? _errorZones;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ZoneManagementModel());
    _loadCities();
    _loadZones();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() {
      _loadingCities = true;
      _errorCities = null;
    });
    try {
      final resp = await GetCitiesCall.call(token: currentAuthenticationToken);
      if (!mounted) return;
      if (resp.succeeded) {
        final data = GetCitiesCall.data(resp.jsonBody);
        setState(() {
          final list = data ?? [];
          list.sort((a, b) {
            final aId = (a['id'] ?? 0) as int;
            final bId = (b['id'] ?? 0) as int;
            return aId.compareTo(bId);
          });
          _cities = list;
          _loadingCities = false;
        });
      } else {
        setState(() {
          _errorCities =
              getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                  'Failed to load cities';
          _loadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorCities = e.toString();
          _loadingCities = false;
        });
      }
    }
  }

  Future<void> _loadZones() async {
    setState(() {
      _loadingZones = true;
      _errorZones = null;
    });
    try {
      final resp = await GetZonesCall.call(token: currentAuthenticationToken);
      if (!mounted) return;
      if (resp.succeeded) {
        final data = GetZonesCall.data(resp.jsonBody);
        setState(() {
          final zlist = data ?? [];
          zlist.sort((a, b) {
            final aId = (a['id'] ?? 0) as int;
            final bId = (b['id'] ?? 0) as int;
            return aId.compareTo(bId);
          });
          _zones = zlist;
          _loadingZones = false;
        });
      } else {
        setState(() {
          _errorZones =
              getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                  'Failed to load zones';
          _loadingZones = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorZones = e.toString();
          _loadingZones = false;
        });
      }
    }
  }

  Future<void> _addCity() async {
    final result = await showDialog<_CityFormData>(
      context: context,
      builder: (ctx) => const _AddCityDialog(),
    );
    if (result == null) return;

    try {
      final resp = await AddCityCall.call(
        token: currentAuthenticationToken,
        name: result.name,
        isActive: result.isActive,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('City created'),
              backgroundColor: Color(0xFF2E7D32)),
        );
        _loadCities();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                    'Failed to add city'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _addZone() async {
    if (_cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a city first')),
      );
      return;
    }

    final result = await showDialog<_ZoneFormData>(
      context: context,
      builder: (ctx) => _AddZoneDialog(cities: _cities),
    );
    if (result == null) return;

    try {
      final resp = await AddZoneCall.call(
        token: currentAuthenticationToken,
        name: result.name,
        cityId: result.cityId,
        type: 'radius',
        centerLat: result.centerLat,
        centerLng: result.centerLng,
        radiusKm: result.radiusKm,
        isActive: result.isActive,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Zone created'),
              backgroundColor: Color(0xFF2E7D32)),
        );
        _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                    'Failed to add zone'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _editCity(dynamic city) async {
    final cityId = castToType<int>(getJsonField(city, r'''$.id'''));
    if (cityId == null) return;

    final result = await showDialog<_CityFormData>(
      context: context,
      builder: (ctx) => _EditCityDialog(
        initialName: getJsonField(city, r'''$.name''')?.toString() ?? '',
        initialActive: getJsonField(city, r'''$.is_active''') == true,
      ),
    );
    if (result == null) return;

    try {
      final resp = await UpdateCityCall.call(
        token: currentAuthenticationToken,
        cityId: cityId,
        name: result.name,
        isActive: result.isActive,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('City updated'),
              backgroundColor: Color(0xFF2E7D32)),
        );
        _loadCities();
        _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                    'Failed to update city'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  Future<void> _deleteCity(dynamic city) async {
    final cityId = castToType<int>(getJsonField(city, r'''$.id'''));
    final cityName =
        getJsonField(city, r'''$.name''')?.toString() ?? 'this city';
    if (cityId == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete city?'),
        content: Text('Are you sure you want to delete "$cityName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final resp = await DeleteCityCall.call(
          token: currentAuthenticationToken, cityId: cityId);
      if (!mounted) return;
      if (resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('City deleted'),
              backgroundColor: Color(0xFF2E7D32)),
        );
        _loadCities();
        _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                    'Failed to delete city'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  Future<void> _editZone(dynamic zone) async {
    final zoneId = castToType<int>(getJsonField(zone, r'''$.id'''));
    if (zoneId == null) return;

    final result = await showDialog<_ZoneFormData>(
      context: context,
      builder: (ctx) => _EditZoneDialog(
        cities: _cities,
        initialName: getJsonField(zone, r'''$.name''')?.toString() ?? '',
        initialCityId: castToType<int>(getJsonField(zone, r'''$.city_id''')),
        initialLat: double.tryParse(
                getJsonField(zone, r'''$.center_lat''')?.toString() ?? '') ??
            12.9716,
        initialLng: double.tryParse(
                getJsonField(zone, r'''$.center_lng''')?.toString() ?? '') ??
            77.5946,
        initialRadius: double.tryParse(
                getJsonField(zone, r'''$.radius_km''')?.toString() ?? '') ??
            10.0,
        initialActive: getJsonField(zone, r'''$.is_active''') == true,
      ),
    );
    if (result == null) return;

    try {
      final resp = await UpdateZoneCall.call(
        token: currentAuthenticationToken,
        zoneId: zoneId,
        cityId: result.cityId,
        name: result.name,
        type: 'radius',
        centerLat: result.centerLat,
        centerLng: result.centerLng,
        radiusKm: result.radiusKm,
        isActive: result.isActive,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Zone updated'),
              backgroundColor: Color(0xFF2E7D32)),
        );
        _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                    'Failed to update zone'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  Future<void> _deleteZone(dynamic zone) async {
    final zoneId = castToType<int>(getJsonField(zone, r'''$.id'''));
    final zoneName =
        getJsonField(zone, r'''$.name''')?.toString() ?? 'this zone';
    if (zoneId == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete zone?'),
        content: Text('Are you sure you want to delete "$zoneName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final resp = await DeleteZoneCall.call(
          token: currentAuthenticationToken, zoneId: zoneId);
      if (!mounted) return;
      if (resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Zone deleted'),
              backgroundColor: Color(0xFF2E7D32)),
        );
        _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
                    'Failed to delete zone'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminScaffold(
      title: 'Zone Management',
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_loadCities(), _loadZones()]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: ResponsiveContainer(
            maxWidth: 1400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.alternate),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Define cities and service zones with radius-based geofences',
                          style: theme.bodyMedium
                              .override(font: GoogleFonts.inter()),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                _buildMetricsSection(theme)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 40.ms)
                  .slideY(
                    begin: 0.02,
                    end: 0,
                    delay: 40.ms,
                    curve: Curves.easeOutCubic),
                const SizedBox(height: 24),

                // Cities section
                Row(
                  children: [
                    Icon(Icons.location_city, color: theme.primary, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      'Cities',
                      style: theme.headlineSmall.override(
                          font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    FFButtonWidget(
                      onPressed: _addCity,
                      text: 'Add City',
                      icon: Icon(Icons.add, color: Colors.white, size: 18),
                      options: FFButtonOptions(
                        height: 40,
                        color: theme.primary,
                        textStyle: theme.titleSmall.override(
                            font: GoogleFonts.inter(), color: Colors.white),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 60.ms).slideX(
                    begin: -0.02,
                    end: 0,
                    delay: 60.ms,
                    curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                _buildCitiesList(theme),
                const SizedBox(height: 28),

                // Zones section
                Row(
                  children: [
                    Icon(Icons.location_on, color: theme.primary, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      'Zones',
                      style: theme.headlineSmall.override(
                          font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    FFButtonWidget(
                      onPressed: _addZone,
                      text: 'Add Zone',
                      icon: Icon(Icons.add, color: Colors.white, size: 18),
                      options: FFButtonOptions(
                        height: 40,
                        color: theme.primary,
                        textStyle: theme.titleSmall.override(
                            font: GoogleFonts.inter(), color: Colors.white),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 120.ms).slideX(
                    begin: -0.02,
                    end: 0,
                    delay: 120.ms,
                    curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                _buildZonesList(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCitiesList(FlutterFlowTheme theme) {
    if (_loadingCities) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (_errorCities != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.error),
            const SizedBox(height: 12),
            Text(_errorCities!,
                textAlign: TextAlign.center, style: theme.bodyMedium),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadCities,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_cities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.location_city_outlined,
                  size: 48, color: theme.secondaryText),
              const SizedBox(height: 12),
              Text('No cities yet',
                  style: theme.bodyLarge.override(color: theme.secondaryText)),
              const SizedBox(height: 8),
              Text('Tap "Add City" to create one',
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minWidth = constraints.maxWidth > 980 ? constraints.maxWidth : 980.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(theme.primaryBackground),
                  dataRowColor: WidgetStatePropertyAll(Colors.white),
                  dividerThickness: 1,
                  headingTextStyle: theme.labelLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    color: theme.primaryText,
                  ),
                  dataTextStyle:
                      theme.bodyMedium.override(font: GoogleFonts.inter()),
                  horizontalMargin: 16,
                  columnSpacing: 26,
                  columns: const [
                    DataColumn(label: Text('City ID')),
                    DataColumn(label: Text('City Name')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Zones Count')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: List.generate(_cities.length, (i) {
                    final city = _cities[i];
                    final id = getJsonField(city, r'''$.id''')?.toString() ?? '—';
                    final cityName =
                        getJsonField(city, r'''$.name''')?.toString() ?? '—';
                    final isActive = getJsonField(city, r'''$.is_active''') == true;
                    final cityIdInt =
                        castToType<int>(getJsonField(city, r'''$.id'''));
                    final zonesCount = cityIdInt == null
                        ? 0
                        : _zones.where((z) {
                            return castToType<int>(
                                    getJsonField(z, r'''$.city_id''')) ==
                                cityIdInt;
                          }).length;
                    return DataRow(
                      cells: [
                        DataCell(Text(id)),
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    theme.primary.withValues(alpha: 0.14),
                                child: Icon(
                                  Icons.location_city,
                                  size: 16,
                                  color: theme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(child: Text(cityName)),
                            ],
                          ),
                        ),
                        DataCell(_buildStatusPill(isActive, theme)),
                        DataCell(Text(zonesCount.toString())),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit city',
                                onPressed: () => _editCity(city),
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: theme.primary,
                                  size: 20,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete city',
                                onPressed: () => _deleteCity(city),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFC62828),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 90.ms)
        .slideY(begin: 0.01, end: 0, delay: 90.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildMetricsSection(FlutterFlowTheme theme) {
    final totalCities = _cities.length;
    final activeCities = _cities
        .where((c) => getJsonField(c, r'''$.is_active''') == true)
        .length;
    final totalZones = _zones.length;
    final activeZones = _zones
        .where((z) => getJsonField(z, r'''$.is_active''') == true)
        .length;

    return DashboardMetricGrid(
      maxWidthForThreeCols: 980,
      childAspectRatioThreeCols: 1.85,
      childAspectRatioTwoCols: 1.65,
      children: [
        DashboardMetricCard(
          title: 'Total Cities',
          value: totalCities.toString(),
          subtitle: _loadingCities ? 'Loading cities...' : null,
          icon: Icons.location_city,
          backgroundColor: const Color(0xFFEFF6FF),
          accentColor: const Color(0xFF1D4ED8),
        ),
        DashboardMetricCard(
          title: 'Active Cities',
          value: activeCities.toString(),
          subtitle: totalCities == 0
              ? null
              : '${((activeCities / totalCities) * 100).toStringAsFixed(0)}% of total',
          icon: Icons.approval_outlined,
          backgroundColor: const Color(0xFFECFDF3),
          accentColor: const Color(0xFF15803D),
        ),
        DashboardMetricCard(
          title: 'Total Zones',
          value: totalZones.toString(),
          subtitle: _loadingZones ? 'Loading zones...' : null,
          icon: Icons.location_on_outlined,
          backgroundColor: const Color(0xFFFFF7ED),
          accentColor: const Color(0xFFC2410C),
        ),
        DashboardMetricCard(
          title: 'Active Zones',
          value: activeZones.toString(),
          subtitle: totalZones == 0
              ? null
              : '${((activeZones / totalZones) * 100).toStringAsFixed(0)}% of total',
          icon: Icons.gpp_good_outlined,
          backgroundColor: const Color(0xFFF5F3FF),
          accentColor: const Color(0xFF6D28D9),
        ),
      ],
    );
  }

  Widget _buildZonesList(FlutterFlowTheme theme) {
    if (_loadingZones) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (_errorZones != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.error),
            const SizedBox(height: 12),
            Text(_errorZones!,
                textAlign: TextAlign.center, style: theme.bodyMedium),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadZones,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_zones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 48, color: theme.secondaryText),
              const SizedBox(height: 12),
              Text('No zones yet',
                  style: theme.bodyLarge.override(color: theme.secondaryText)),
              const SizedBox(height: 8),
              Text('Add a city first, then create zones',
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minWidth =
                constraints.maxWidth > 1180 ? constraints.maxWidth : 1180.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child: DataTable(
              headingRowColor: WidgetStatePropertyAll(theme.primaryBackground),
              dataRowColor: WidgetStatePropertyAll(Colors.white),
              dividerThickness: 1,
              headingTextStyle: theme.labelLarge.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                color: theme.primaryText,
              ),
              dataTextStyle:
                  theme.bodyMedium.override(font: GoogleFonts.inter()),
              horizontalMargin: 16,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Zone ID')),
                DataColumn(label: Text('Zone Name')),
                DataColumn(label: Text('City')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Radius (km)')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: List.generate(_zones.length, (i) {
                final zone = _zones[i];
                final id = getJsonField(zone, r'''$.id''')?.toString() ?? '—';
                final zoneName =
                    getJsonField(zone, r'''$.name''')?.toString() ?? '—';
                final type =
                    getJsonField(zone, r'''$.type''')?.toString() ?? 'radius';
                final radius =
                    getJsonField(zone, r'''$.radius_km''')?.toString() ?? '—';
                final cityId =
                    castToType<int>(getJsonField(zone, r'''$.city_id'''));
                dynamic matchedCity;
                for (final c in _cities) {
                  if (castToType<int>(getJsonField(c, r'''$.id''')) == cityId) {
                    matchedCity = c;
                    break;
                  }
                }
                final cityName =
                    getJsonField(matchedCity, r'''$.name''')?.toString() ??
                        'City ${cityId ?? '—'}';
                final isActive = getJsonField(zone, r'''$.is_active''') == true;

                return DataRow(
                  cells: [
                    DataCell(Text(id)),
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                theme.primary.withValues(alpha: 0.14),
                            child: Icon(
                              Icons.location_on,
                              size: 16,
                              color: theme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(child: Text(zoneName)),
                        ],
                      ),
                    ),
                    DataCell(Text(cityName)),
                    DataCell(Text(type)),
                    DataCell(Text(radius)),
                    DataCell(_buildStatusPill(isActive, theme)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit zone',
                            onPressed: () => _editZone(zone),
                            icon: Icon(
                              Icons.edit_outlined,
                              color: theme.primary,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete zone',
                            onPressed: () => _deleteZone(zone),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFC62828),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
                ),
              ),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 120.ms)
        .slideY(begin: 0.01, end: 0, delay: 120.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStatusPill(bool isActive, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0x1F2E7D32) : const Color(0x1FE65100),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: theme.labelSmall.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
          color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
        ),
      ),
    );
  }
}

class _CityFormData {
  _CityFormData({required this.name, required this.isActive});
  final String name;
  final bool isActive;
}

class _ZoneFormData {
  _ZoneFormData({
    required this.name,
    required this.cityId,
    required this.centerLat,
    required this.centerLng,
    required this.radiusKm,
    required this.isActive,
  });
  final String name;
  final int cityId;
  final double centerLat;
  final double centerLng;
  final double radiusKm;
  final bool isActive;
}

class _AddCityDialog extends StatefulWidget {
  const _AddCityDialog();

  @override
  State<_AddCityDialog> createState() => _AddCityDialogState();
}

class _EditCityDialog extends StatefulWidget {
  const _EditCityDialog(
      {required this.initialName, required this.initialActive});

  final String initialName;
  final bool initialActive;

  @override
  State<_EditCityDialog> createState() => _EditCityDialogState();
}

class _EditCityDialogState extends State<_EditCityDialog> {
  late TextEditingController _nameController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _isActive = widget.initialActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit City'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'City Name'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter city name')),
              );
              return;
            }
            Navigator.pop(
                context,
                _CityFormData(
                  name: _nameController.text.trim(),
                  isActive: _isActive,
                ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddCityDialogState extends State<_AddCityDialog> {
  late TextEditingController _nameController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add City'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'City Name',
                hintText: 'e.g. Bangalore',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter city name')),
              );
              return;
            }
            Navigator.pop(
                context,
                _CityFormData(
                  name: _nameController.text.trim(),
                  isActive: _isActive,
                ));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddZoneDialog extends StatefulWidget {
  const _AddZoneDialog({required this.cities});
  final List<dynamic> cities;

  @override
  State<_AddZoneDialog> createState() => _AddZoneDialogState();
}

class _EditZoneDialog extends StatefulWidget {
  const _EditZoneDialog({
    required this.cities,
    required this.initialName,
    required this.initialCityId,
    required this.initialLat,
    required this.initialLng,
    required this.initialRadius,
    required this.initialActive,
  });

  final List<dynamic> cities;
  final String initialName;
  final int? initialCityId;
  final double initialLat;
  final double initialLng;
  final double initialRadius;
  final bool initialActive;

  @override
  State<_EditZoneDialog> createState() => _EditZoneDialogState();
}

class _EditZoneDialogState extends State<_EditZoneDialog> {
  late TextEditingController _nameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;
  int? _selectedCityId;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _latController = TextEditingController(text: widget.initialLat.toString());
    _lngController = TextEditingController(text: widget.initialLng.toString());
    _radiusController =
        TextEditingController(text: widget.initialRadius.toString());
    _selectedCityId = widget.initialCityId ??
        (widget.cities.isNotEmpty
            ? castToType<int>(getJsonField(widget.cities.first, r'''$.id'''))
            : null);
    _isActive = widget.initialActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Zone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedCityId,
              decoration: const InputDecoration(labelText: 'City'),
              items: widget.cities.map((c) {
                final id = castToType<int>(getJsonField(c, r'''$.id'''));
                final name = getJsonField(c, r'''$.name''')?.toString() ?? '—';
                return DropdownMenuItem(value: id, child: Text(name));
              }).toList(),
              onChanged: (v) => setState(() => _selectedCityId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Zone Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(labelText: 'Center Latitude'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lngController,
              decoration: const InputDecoration(labelText: 'Center Longitude'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(labelText: 'Radius (km)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter zone name')),
              );
              return;
            }
            if (_selectedCityId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select a city')),
              );
              return;
            }
            Navigator.pop(
                context,
                _ZoneFormData(
                  name: _nameController.text.trim(),
                  cityId: _selectedCityId!,
                  centerLat: double.tryParse(_latController.text) ?? 12.9716,
                  centerLng: double.tryParse(_lngController.text) ?? 77.5946,
                  radiusKm: double.tryParse(_radiusController.text) ?? 10.0,
                  isActive: _isActive,
                ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddZoneDialogState extends State<_AddZoneDialog> {
  late TextEditingController _nameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;
  int? _selectedCityId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _latController = TextEditingController(text: '12.9716');
    _lngController = TextEditingController(text: '77.5946');
    _radiusController = TextEditingController(text: '10');
    if (widget.cities.isNotEmpty) {
      _selectedCityId =
          castToType<int>(getJsonField(widget.cities[0], r'''$.id'''));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Zone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedCityId,
              decoration: const InputDecoration(labelText: 'City'),
              items: widget.cities.map((c) {
                final id = castToType<int>(getJsonField(c, r'''$.id'''));
                final name = getJsonField(c, r'''$.name''')?.toString() ?? '—';
                return DropdownMenuItem(value: id, child: Text(name));
              }).toList(),
              onChanged: (v) => setState(() => _selectedCityId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Zone Name',
                hintText: 'e.g. Central Zone',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(labelText: 'Center Latitude'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lngController,
              decoration: const InputDecoration(labelText: 'Center Longitude'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(labelText: 'Radius (km)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter zone name')),
              );
              return;
            }
            if (_selectedCityId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select a city')),
              );
              return;
            }
            Navigator.pop(
                context,
                _ZoneFormData(
                  name: _nameController.text.trim(),
                  cityId: _selectedCityId!,
                  centerLat: double.tryParse(_latController.text) ?? 12.9716,
                  centerLng: double.tryParse(_lngController.text) ?? 77.5946,
                  radiusKm: double.tryParse(_radiusController.text) ?? 10.0,
                  isActive: _isActive,
                ));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
