import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/admin_scaffold.dart';
import 'fare_surge_settings_model.dart';
export 'fare_surge_settings_model.dart';

class FareSurgeSettingsWidget extends StatefulWidget {
  const FareSurgeSettingsWidget({super.key});

  static String routeName = 'FareSurgeSettings';
  static String routePath = '/fare-surge-settings';

  @override
  State<FareSurgeSettingsWidget> createState() => _FareSurgeSettingsWidgetState();
}

class _FareSurgeSettingsWidgetState extends State<FareSurgeSettingsWidget> {
  late FareSurgeSettingsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FareSurgeSettingsModel());
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
      title: 'Fare & Surge Settings',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsCard(
            'Base Fare',
            'Starting fare for all rides',
            '₹40',
            Icons.money, theme,
          ),
          _settingsCard(
            'Per KM Charge',
            'Charge per kilometer',
            '₹15/km',
            Icons.straighten, theme,
          ),
          _settingsCard(
            'Per Minute Charge',
            'Waiting time charge',
            '₹2/min',
            Icons.timer, theme,
          ),
          _settingsCard(
            'Surge Pricing',
            'Peak hours multiplier',
            '1.2x - 2.0x',
            Icons.trending_up, theme,
          ),
          _settingsCard(
            'Tax',
            'Service tax',
            '5%',
            Icons.receipt, theme,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(String title, String subtitle, String value, IconData icon, FlutterFlowTheme theme) {
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
            backgroundColor: theme.primary.withValues(alpha:0.2),
            child: Icon(icon, color: theme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.titleMedium.override(font: GoogleFonts.inter())),
                Text(subtitle, style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.secondaryText)),
              ],
            ),
          ),
          Text(value, style: theme.titleMedium.override(font: GoogleFonts.inter(), color: theme.primary)),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit, color: theme.primary, size: 20),
          ),
        ],
      ),
    );
  }
}
