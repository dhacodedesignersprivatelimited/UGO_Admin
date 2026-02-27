import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/admin_scaffold.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LiveDriverMapModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminScaffold(
      title: 'Live Driver Map',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.secondaryBackground,
            child: Row(
              children: [
                _filterChip(context, 'Online', true, theme),
                const SizedBox(width: 8),
                _filterChip(context, 'On Trip', false, theme),
                const SizedBox(width: 8),
                _filterChip(context, 'Offline', false, theme),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.alternate),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 80, color: theme.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Map View',
                      style: theme.headlineSmall.override(font: GoogleFonts.inter()),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Integrate Google Maps / Mapbox for live driver tracking',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Locations'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, bool selected, FlutterFlowTheme theme) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => safeSetState(() {}),
      selectedColor: theme.primary.withOpacity(0.3),
      checkmarkColor: theme.primary,
    );
  }
}
