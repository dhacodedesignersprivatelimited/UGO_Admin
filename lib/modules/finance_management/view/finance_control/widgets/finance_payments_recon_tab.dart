import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';

/// GET `/api/admins/payments/reconciliation` (+ optional legacy getall note).
class FinancePaymentsReconTab extends StatefulWidget {
  const FinancePaymentsReconTab({super.key});

  @override
  State<FinancePaymentsReconTab> createState() => _FinancePaymentsReconTabState();
}

class _FinancePaymentsReconTabState extends State<FinancePaymentsReconTab> {
  bool _loading = true;
  String? _error;
  List<dynamic> _byStatus = const [];
  List<dynamic> _orphans = const [];
  List<dynamic> _mismatch = const [];
  List<dynamic> _failed = const [];

  @override
  void initState() {
    super.initState();
    _load();
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
    try {
      final r = await GetAdminPaymentsReconciliationCall.call(token: token, sampleLimit: 30);
      if (!r.succeeded) {
        setState(() {
          _loading = false;
          _error = getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Request failed';
        });
        return;
      }
      final data = getJsonField(r.jsonBody, r'''$.data''') as Map<String, dynamic>?;
      setState(() {
        _loading = false;
        _byStatus = List<dynamic>.from(data?['by_status'] as List? ?? const []);
        _orphans = List<dynamic>.from(data?['success_without_capture'] as List? ?? const []);
        _mismatch = List<dynamic>.from(data?['amount_mismatch_with_capture'] as List? ?? const []);
        _failed = List<dynamic>.from(data?['failed_or_error_recent'] as List? ?? const []);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(_error!, textAlign: TextAlign.center)),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Payment reconciliation', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
            ],
          ),
          Text('GET /api/admins/payments/reconciliation', style: theme.bodySmall),
          const SizedBox(height: 12),
          Text('Status dashboard', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _byStatus.map((s) {
              final m = s as Map<String, dynamic>;
              return Chip(label: Text('${m['status']}: ${m['count']} (₹${m['amount_inr']})'));
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Failed / non-success (sample)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_failed.isEmpty)
            Text('None in sample.', style: theme.bodySmall)
          else
            ..._failed.map((e) => _row(theme, e as Map<String, dynamic>)),
          const SizedBox(height: 20),
          Text('Success without ride capture', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_orphans.isEmpty)
            Text('None in sample.', style: theme.bodySmall)
          else
            ..._orphans.map((e) => _row(theme, e as Map<String, dynamic>)),
          const SizedBox(height: 20),
          Text('Amount mismatch (payment vs capture)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_mismatch.isEmpty)
            Text('None in sample.', style: theme.bodySmall)
          else
            ..._mismatch.map((e) => _row(theme, e as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _row(FlutterFlowTheme theme, Map<String, dynamic> m) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: Text('Payment #${m['id']} ride ${m['ride_id']}', style: GoogleFonts.jetBrainsMono(fontSize: 12)),
        subtitle: Text('${m['payment_status'] ?? m['amount'] ?? ''} amt ${m['amount'] ?? m['payment_amount'] ?? ''} cap ${m['capture_amount'] ?? ''}\n${m['created_at'] ?? ''}', maxLines: 3),
      ),
    );
  }
}
