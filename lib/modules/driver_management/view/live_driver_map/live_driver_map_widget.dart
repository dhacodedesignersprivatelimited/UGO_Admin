import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/network/api_config.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/shared/widgets/safe_network_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'live_driver_map_model.dart';
export 'live_driver_map_model.dart';

class LiveDriverMapWidget extends StatefulWidget {
  const LiveDriverMapWidget({super.key});

  static String routeName = 'LiveDriverMap';
  static String routePath = '/live-driver-map';

  @override
  State<LiveDriverMapWidget> createState() => _LiveDriverMapWidgetState();
}

class _LiveDriverMapWidgetState extends State<LiveDriverMapWidget> {
  late LiveDriverMapModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<ApiCallResponse> _driversFuture;
  String _selectedFilter = 'Online';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LiveDriverMapModel());
    _fetchDrivers();
  }

  void _fetchDrivers() {
    setState(() {
      _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _isDriverOnline(dynamic d) {
    final val = getJsonField(d, r'''$.is_online''');
    if (val == null) return false;
    if (val is bool) return val;
    return val.toString().toLowerCase() == 'true';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminScaffold(
      title: 'Live Driver Map',
      child: FutureBuilder<ApiCallResponse>(
        future: _driversFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: theme.primary));
          }

          final response = snapshot.data!;
          final allDrivers = GetDriversCall.data(response.jsonBody)?.toList() ?? [];

          // Note: "On Trip" might require additional backend fields like status=='on_trip'.
          // For now, filtering mainly by is_online.
          final filteredDrivers = allDrivers.where((d) {
            final isOnline = _isDriverOnline(d);
            if (_selectedFilter == 'Online') return isOnline;
            if (_selectedFilter == 'Offline') return !isOnline;
            // If On Trip, ideally we check d['status'] == 'on_trip'. 
            // We'll just return isOnline as a placeholder for now.
            if (_selectedFilter == 'On Trip') return isOnline; 
            return true;
          }).toList();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Area (Left)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: theme.secondaryBackground,
                      child: Row(
                        children: [
                          _filterChip(context, 'Online', _selectedFilter == 'Online', theme),
                          const SizedBox(width: 8),
                          _filterChip(context, 'On Trip', _selectedFilter == 'On Trip', theme),
                          const SizedBox(width: 8),
                          _filterChip(context, 'Offline', _selectedFilter == 'Offline', theme),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            onPressed: _fetchDrivers,
                            tooltip: 'Refresh Drivers',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.alternate,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_rounded, size: 80, color: theme.primary.withValues(alpha:0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'Live Map View',
                                style: theme.headlineSmall.override(font: GoogleFonts.interTight(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Integrate Google Maps / Mapbox here',
                                textAlign: TextAlign.center,
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List Area (Right)
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  border: Border(left: BorderSide(color: theme.alternate)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: theme.alternate)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '$_selectedFilter Drivers',
                            style: theme.titleMedium.override(
                              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filteredDrivers.length}',
                              style: theme.bodyMedium.override(
                                color: theme.primary,
                                font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredDrivers.isEmpty
                          ? Center(
                              child: Text(
                                'No drivers found',
                                style: theme.bodyMedium.override(color: theme.secondaryText),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredDrivers.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: theme.alternate.withValues(alpha: 0.5)),
                              itemBuilder: (context, index) {
                                final d = filteredDrivers[index];
                                final firstName = getJsonField(d, r'''$.first_name''')?.toString() ?? '';
                                final lastName = getJsonField(d, r'''$.last_name''')?.toString() ?? '';
                                final name = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : 'Unknown';
                                final phone = getJsonField(d, r'''$.mobile_number''')?.toString() ?? 'No phone';
                                final img = getJsonField(d, r'''$.profile_image''')?.toString();
                                final isOnline = _isDriverOnline(d);

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: Stack(
                                    children: [
                                      SafeNetworkAvatar(
                                        imageUrl: img != null && img.isNotEmpty && img != 'null'
                                            ? (img.startsWith('http') ? img : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}')
                                            : '',
                                        radius: 20,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: isOnline ? const Color(0xFF00C853) : const Color(0xFF9E9E9E),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: theme.secondaryBackground, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    name,
                                    style: theme.bodyMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                  ),
                                  subtitle: Text(
                                    phone,
                                    style: theme.bodySmall.override(color: theme.secondaryText),
                                  ),
                                  trailing: Icon(Icons.chevron_right_rounded, color: theme.alternate, size: 20),
                                  onTap: () {
                                    final dId = getJsonField(d, r'''$.id''');
                                    if (dId != null) {
                                      // Optional: Route to Driver Details, or focus on map.
                                      // context.pushNamedAuth(DriverDetailsWidget.routeName, context.mounted, queryParameters: {'driverId': dId.toString()});
                                    }
                                  },
                                );
                              },
                            ).animate().fadeIn(duration: 300.ms),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, bool selected, FlutterFlowTheme theme) {
    return FilterChip(
      label: Text(label, style: theme.bodySmall.override(
        color: selected ? theme.primary : theme.primaryText,
        font: GoogleFonts.inter(fontWeight: selected ? FontWeight.bold : FontWeight.normal),
      )),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = label),
      selectedColor: theme.primary.withValues(alpha:0.15),
      checkmarkColor: theme.primary,
      backgroundColor: theme.secondaryBackground,
      side: BorderSide(color: selected ? theme.primary : theme.alternate),
    );
  }
}
