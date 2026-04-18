import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// GET `/api/admins/ledger` with filters and server pagination.
class LedgerExplorerTab extends StatefulWidget {
  const LedgerExplorerTab({
    super.key,
    this.initialRideId,
    this.initialUserId,
    this.initialDriverId,
  });

  final int? initialRideId;
  final int? initialUserId;
  final int? initialDriverId;

  @override
  State<LedgerExplorerTab> createState() => _LedgerExplorerTabState();
}

class _LedgerExplorerTabState extends State<LedgerExplorerTab> {
  final _ride = TextEditingController();
  final _user = TextEditingController();
  final _driver = TextEditingController();
  final _txnType = TextEditingController();
  final _amtMin = TextEditingController();
  final _amtMax = TextEditingController();
  DateTime? _from;
  DateTime? _to;

  bool _loading = false;
  String? _error;
  List<dynamic> _entries = const [];
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  static const _limit = 25;

  @override
  void initState() {
    super.initState();
    if (widget.initialRideId != null) {
      _ride.text = '${widget.initialRideId}';
    }
    if (widget.initialUserId != null) {
      _user.text = '${widget.initialUserId}';
    }
    if (widget.initialDriverId != null) {
      _driver.text = '${widget.initialDriverId}';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch(page: 1));
  }

  @override
  void dispose() {
    _ride.dispose();
    _user.dispose();
    _driver.dispose();
    _txnType.dispose();
    _amtMin.dispose();
    _amtMax.dispose();
    super.dispose();
  }

  int? _parseId(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _from = d);
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _to = d);
  }

  Future<void> _fetch({int? page}) async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Not signed in');
      return;
    }
    final p = page ?? _page;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await GetAdminLedgerCall.call(
        token: token,
        page: p,
        limit: _limit,
        rideId: _parseId(_ride.text),
        userId: _parseId(_user.text),
        driverId: _parseId(_driver.text),
        txnType: _txnType.text.trim().isEmpty ? null : _txnType.text.trim(),
        from: _from?.toIso8601String(),
        to: _to?.toIso8601String(),
        amountMin: _amtMin.text.trim().isEmpty ? null : _amtMin.text.trim(),
        amountMax: _amtMax.text.trim().isEmpty ? null : _amtMax.text.trim(),
      );
      if (!r.succeeded) {
        setState(() {
          _loading = false;
          _error = getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Request failed';
        });
        return;
      }
      setState(() {
        _loading = false;
        _page = p;
        _entries = GetAdminLedgerCall.entriesList(r.jsonBody);
        _total = GetAdminLedgerCall.total(r.jsonBody);
        _totalPages = GetAdminLedgerCall.totalPages(r.jsonBody);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Ledger explorer',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _ride,
                  decoration: const InputDecoration(labelText: 'ride_id', isDense: true),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _user,
                  decoration: const InputDecoration(labelText: 'user_id', isDense: true),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _driver,
                  decoration: const InputDecoration(labelText: 'driver_id', isDense: true),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(controller: _txnType, decoration: const InputDecoration(labelText: 'txn_type', isDense: true)),
              ),
              SizedBox(
                width: 90,
                child: TextField(controller: _amtMin, decoration: const InputDecoration(labelText: 'amt min', isDense: true)),
              ),
              SizedBox(
                width: 90,
                child: TextField(controller: _amtMax, decoration: const InputDecoration(labelText: 'amt max', isDense: true)),
              ),
              OutlinedButton(onPressed: _pickFrom, child: Text(_from == null ? 'From date' : _from!.toString().split(' ').first)),
              OutlinedButton(onPressed: _pickTo, child: Text(_to == null ? 'To date' : _to!.toString().split(' ').first)),
              FilledButton(onPressed: _loading ? null : () => _fetch(page: 1), child: const Text('Search')),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_error!, style: TextStyle(color: theme.error)),
          ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: _entries.isEmpty && !_loading
              ? Center(child: Text('No entries', style: theme.bodySmall))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: _entries.length,
                  itemBuilder: (context, i) {
                    final m = _entries[i] as Map<String, dynamic>;
                    final wa = m['wallet_account'] as Map<String, dynamic>?;
                    final party = wa == null
                        ? ''
                        : 'u:${wa['user_id']} d:${wa['driver_id']} ${wa['party_type'] ?? ''}';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          '${m['entry_type']} · ₹${m['amount']} · ${m['reference_type']}:${m['reference_id']}',
                          style: GoogleFonts.jetBrainsMono(fontSize: 12),
                        ),
                        subtitle: Text(
                          '${m['created_at']}\n$party\n${m['idempotency_key'] ?? ''}',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total $_total · page $_page / $_totalPages', style: theme.bodySmall),
              Row(
                children: [
                  IconButton(
                    onPressed: !_loading && _page > 1 ? () => _fetch(page: _page - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: !_loading && _page < _totalPages ? () => _fetch(page: _page + 1) : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
