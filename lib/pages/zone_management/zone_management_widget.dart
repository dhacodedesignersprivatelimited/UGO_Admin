import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_scaffold.dart';
import '/components/responsive_body.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
          _cities = data ?? [];
          _loadingCities = false;
        });
      } else {
        setState(() {
          _errorCities = getJsonField(resp.jsonBody, r'''$.message''')?.toString() ?? 'Failed to load cities';
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
          _zones = data ?? [];
          _loadingZones = false;
        });
      } else {
        setState(() {
          _errorZones = getJsonField(resp.jsonBody, r'''$.message''')?.toString() ?? 'Failed to load zones';
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
          const SnackBar(content: Text('City created'), backgroundColor: Color(0xFF2E7D32)),
        );
        _loadCities();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getJsonField(resp.jsonBody, r'''$.message''')?.toString() ?? 'Failed to add city'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
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
          const SnackBar(content: Text('Zone created'), backgroundColor: Color(0xFF2E7D32)),
        );
        _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getJsonField(resp.jsonBody, r'''$.message''')?.toString() ?? 'Failed to add zone'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
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
            maxWidth: 900,
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
                          style: theme.bodyMedium.override(font: GoogleFonts.inter()),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),

                // Cities section
                Row(
                  children: [
                    Icon(Icons.location_city, color: theme.primary, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      'Cities',
                      style: theme.headlineSmall.override(font: GoogleFonts.interTight(fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    FFButtonWidget(
                      onPressed: _addCity,
                      text: 'Add City',
                      icon: Icon(Icons.add, color: Colors.white, size: 18),
                      options: FFButtonOptions(
                        height: 40,
                        color: theme.primary,
                        textStyle: theme.titleSmall.override(font: GoogleFonts.inter(), color: Colors.white),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 60.ms)
                    .slideX(begin: -0.02, end: 0, delay: 60.ms, curve: Curves.easeOutCubic),
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
                      style: theme.headlineSmall.override(font: GoogleFonts.interTight(fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    FFButtonWidget(
                      onPressed: _addZone,
                      text: 'Add Zone',
                      icon: Icon(Icons.add, color: Colors.white, size: 18),
                      options: FFButtonOptions(
                        height: 40,
                        color: theme.primary,
                        textStyle: theme.titleSmall.override(font: GoogleFonts.inter(), color: Colors.white),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 120.ms)
                    .slideX(begin: -0.02, end: 0, delay: 120.ms, curve: Curves.easeOutCubic),
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
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
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
            Text(_errorCities!, textAlign: TextAlign.center, style: theme.bodyMedium),
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
              Icon(Icons.location_city_outlined, size: 48, color: theme.secondaryText),
              const SizedBox(height: 12),
              Text('No cities yet', style: theme.bodyLarge.override(color: theme.secondaryText)),
              const SizedBox(height: 8),
              Text('Tap "Add City" to create one', style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: List.generate(_cities.length, (i) {
        final c = _cities[i];
        final id = getJsonField(c, r'''$.id''');
        final name = getJsonField(c, r'''$.name''')?.toString() ?? '—';
        final isActive = getJsonField(c, r'''$.is_active''') == true;
        return _buildCityCard(id, name, isActive, theme, i);
      }),
    );
  }

  Widget _buildCityCard(dynamic id, String name, bool isActive, FlutterFlowTheme theme, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primary.withValues(alpha:0.2),
            child: Icon(Icons.location_city, color: theme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.titleMedium.override(font: GoogleFonts.inter())),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withValues(alpha:0.2) : Colors.orange.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: theme.labelSmall.override(
                      font: GoogleFonts.inter(),
                      color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (id != null) Text('ID: $id', style: theme.labelSmall.override(color: theme.secondaryText)),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (80 + index * 50).ms)
        .slideX(begin: 0.03, end: 0, delay: (80 + index * 50).ms, curve: Curves.easeOutCubic);
  }

  Widget _buildZonesList(FlutterFlowTheme theme) {
    if (_loadingZones) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
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
            Text(_errorZones!, textAlign: TextAlign.center, style: theme.bodyMedium),
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
              Icon(Icons.location_on_outlined, size: 48, color: theme.secondaryText),
              const SizedBox(height: 12),
              Text('No zones yet', style: theme.bodyLarge.override(color: theme.secondaryText)),
              const SizedBox(height: 8),
              Text('Add a city first, then create zones', style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: List.generate(_zones.length, (i) {
        final z = _zones[i];
        final id = getJsonField(z, r'''$.id''');
        final name = getJsonField(z, r'''$.name''')?.toString() ?? '—';
        final type = getJsonField(z, r'''$.type''')?.toString() ?? 'radius';
        final radius = getJsonField(z, r'''$.radius_km''')?.toString();
        final cityId = getJsonField(z, r'''$.city_id''');
        final cityName = () {
          for (final c in _cities) {
            if (castToType<int>(getJsonField(c, r'''$.id''')) == castToType<int>(cityId)) {
              return getJsonField(c, r'''$.name''')?.toString() ?? 'City $cityId';
            }
          }
          return 'City $cityId';
        }();
        final isActive = getJsonField(z, r'''$.is_active''') == true;
        final desc = type == 'radius' && radius != null ? '${radius} km radius' : type;
        return _buildZoneCard(id, name, '$cityName • $desc', isActive, theme, i);
      }),
    );
  }

  Widget _buildZoneCard(dynamic id, String name, String desc, bool isActive, FlutterFlowTheme theme, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primary.withValues(alpha:0.2),
            child: Icon(Icons.location_on, color: theme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.titleMedium.override(font: GoogleFonts.inter())),
                Text(desc, style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.secondaryText)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withValues(alpha:0.2) : Colors.orange.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: theme.labelSmall.override(
                      font: GoogleFonts.inter(),
                      color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (id != null) Text('ID: $id', style: theme.labelSmall.override(color: theme.secondaryText)),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (120 + index * 50).ms)
        .slideX(begin: 0.03, end: 0, delay: (120 + index * 50).ms, curve: Curves.easeOutCubic);
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
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter city name')),
              );
              return;
            }
            Navigator.pop(context, _CityFormData(
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
      _selectedCityId = castToType<int>(getJsonField(widget.cities[0], r'''$.id'''));
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lngController,
              decoration: const InputDecoration(labelText: 'Center Longitude'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(labelText: 'Radius (km)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
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
            Navigator.pop(context, _ZoneFormData(
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
