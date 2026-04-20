import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import 'fare_surge_settings_model.dart';
export 'fare_surge_settings_model.dart';

/// Loads and saves global finance knobs from `/api/admin-finance/get/finance-settings`
/// (same contract as [GetFinanceSettingsCall] / [UpdateFinanceSettingsCall]).
class FareSurgeSettingsWidget extends StatefulWidget {
  const FareSurgeSettingsWidget({super.key});

  static String routeName = 'FareSurgeSettings';
  static String routePath = '/fare-surge-settings';

  @override
  State<FareSurgeSettingsWidget> createState() => _FareSurgeSettingsWidgetState();
}

class _FareSurgeSettingsWidgetState extends State<FareSurgeSettingsWidget> {
  late FareSurgeSettingsModel _model;
  final _adminPct = TextEditingController();
  final _refPct = TextEditingController();
  final _settleH = TextEditingController();
  final _settleM = TextEditingController();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FareSurgeSettingsModel());
    _load();
  }

  @override
  void dispose() {
    _adminPct.dispose();
    _refPct.dispose();
    _settleH.dispose();
    _settleM.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not signed in';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await GetFinanceSettingsCall.call(token: token);
    if (!mounted) return;
    if (!r.succeeded) {
      setState(() {
        _loading = false;
        _error = getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed to load';
      });
      return;
    }
    final data = getJsonField(r.jsonBody, r'''$.data''');
    final m = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    setState(() {
      _loading = false;
      _adminPct.text = (m['admin_commission_percent'] ?? '').toString();
      _refPct.text = (m['referral_commission_percent'] ?? '').toString();
      _settleH.text = (m['settlement_hour'] ?? '').toString();
      _settleM.text = (m['settlement_minute'] ?? '').toString();
    });
  }

  Future<void> _save() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    final admin = double.tryParse(_adminPct.text.trim());
    final ref = double.tryParse(_refPct.text.trim());
    final h = int.tryParse(_settleH.text.trim());
    final mi = int.tryParse(_settleM.text.trim());
    if (admin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin commission % must be a number')),
      );
      return;
    }
    final r = await UpdateFinanceSettingsCall.call(
      token: token,
      adminCommissionPercent: admin,
      referralCommissionPercent: ref ?? 0,
      settlementHour: h ?? 0,
      settlementMinute: mi ?? 0,
    );
    if (!mounted) return;
    if (!r.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Save failed'),
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finance settings saved')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminScaffold(
      title: 'Fare & finance settings',
      actions: [
        IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh_rounded)),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: TextStyle(color: theme.error)),
                  ),
                Text(
                  'These values map to admin-finance finance-settings (commission, referral %, settlement time). '
                  'Per-vehicle fare tables still use Vehicles / pricing APIs elsewhere.',
                  style: theme.bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _field(theme, 'Admin commission %', _adminPct),
                _field(theme, 'Referral commission %', _refPct),
                _field(theme, 'Settlement hour (0–23)', _settleH),
                _field(theme, 'Settlement minute (0–59)', _settleM),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                ),
              ],
            ),
    );
  }

  Widget _field(FlutterFlowTheme theme, String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: theme.secondaryBackground,
        ),
      ),
    );
  }
}
