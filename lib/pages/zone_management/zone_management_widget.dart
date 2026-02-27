import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/admin_scaffold.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ZoneManagementModel());
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
      title: 'Zone Management',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                    'Define service areas, geofences, and zone-based pricing',
                    style: theme.bodyMedium.override(font: GoogleFonts.inter()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _zoneCard('Downtown', '5km radius', 3, theme),
          _zoneCard('Airport', 'Special zone', 2, theme),
          _zoneCard('Suburb North', '10km radius', 4, theme),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add New Zone'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primary,
              side: BorderSide(color: theme.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneCard(String name, String desc, int drivers, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primary.withOpacity(0.2),
            child: Icon(Icons.location_on, color: theme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.titleMedium.override(font: GoogleFonts.inter())),
                Text(desc, style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.secondaryText)),
              ],
            ),
          ),
          Text('$drivers drivers', style: theme.labelMedium.override(font: GoogleFonts.inter())),
          IconButton(onPressed: () {}, icon: Icon(Icons.edit, color: theme.primary, size: 20)),
        ],
      ),
    );
  }
}
