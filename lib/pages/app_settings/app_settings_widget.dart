import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/admin_scaffold.dart';
import '/main.dart';
import 'app_settings_model.dart';
export 'app_settings_model.dart';

class AppSettingsWidget extends StatefulWidget {
  const AppSettingsWidget({super.key});

  static String routeName = 'AppSettings';
  static String routePath = '/app-settings';

  @override
  State<AppSettingsWidget> createState() => _AppSettingsWidgetState();
}

class _AppSettingsWidgetState extends State<AppSettingsWidget> {
  late AppSettingsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppSettingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final currentMode = FlutterFlowTheme.themeMode;
    final isDark = currentMode == ThemeMode.dark;

    return AdminScaffold(
      title: 'App Settings',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsTile(
            'Dark Mode',
            'Use dark theme for admin panel',
            Switch(
              value: isDark,
              onChanged: (v) {
                MyApp.of(context).setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
              },
              activeColor: theme.primary,
            ),
            theme,
          ),
          _settingsTile(
            'Currency',
            'INR',
            const Icon(Icons.arrow_forward_ios, size: 16),
            theme,
          ),
          _settingsTile(
            'Driver Timeout',
            '30 seconds',
            const Icon(Icons.arrow_forward_ios, size: 16),
            theme,
          ),
          _settingsTile(
            'Notifications',
            'Enable push notifications',
            Switch(value: true, onChanged: (_) {}, activeColor: theme.primary),
            theme,
          ),
          const SizedBox(height: 24),
          Text('API Configuration', style: theme.titleMedium.override(font: GoogleFonts.inter())),
          const SizedBox(height: 12),
          _settingsTile(
            'Google Maps API',
            'Configure API key',
            const Icon(Icons.arrow_forward_ios, size: 16),
            theme,
          ),
          _settingsTile(
            'Firebase Config',
            'Manage Firebase keys',
            const Icon(Icons.arrow_forward_ios, size: 16),
            theme,
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

  Widget _settingsTile(String title, String subtitle, Widget trailing, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.titleSmall.override(font: GoogleFonts.inter())),
                Text(subtitle, style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.secondaryText)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
