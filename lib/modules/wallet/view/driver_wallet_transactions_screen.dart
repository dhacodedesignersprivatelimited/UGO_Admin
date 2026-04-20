import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_scaffold.dart';

class DriverWalletTransactionsScreen extends StatefulWidget {
  const DriverWalletTransactionsScreen({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.showCredits,
  });

  final int driverId;
  final String driverName;
  final bool showCredits;

  @override
  State<DriverWalletTransactionsScreen> createState() =>
      _DriverWalletTransactionsScreenState();
}

class _DriverWalletTransactionsScreenState
    extends State<DriverWalletTransactionsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = [];

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
        _error = 'Session expired. Please login again.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await GetDriverWalletTransactionsCall.call(
        driverId: widget.driverId,
        token: token,
        page: 1,
        pageSize: 50,
      );
      if (!resp.succeeded) {
        setState(() {
          _loading = false;
          _error = 'Failed to load transactions (${resp.statusCode}).';
        });
        return;
      }

      final all = GetDriverWalletTransactionsCall.transactionsList(resp.jsonBody)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      final filtered = all.where((r) => _isCredit(r) == widget.showCredits).toList();

      setState(() {
        _rows = filtered;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Something went wrong while fetching transactions.';
      });
    }
  }

  bool _isCredit(Map<String, dynamic> row) {
    final t = (row['type']?.toString() ?? '').toLowerCase();
    return t.contains('credit') || t.contains('recharge') || t.contains('bonus');
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.showCredits ? 'Credited Transactions' : 'Deducted Transactions';
    return AdminScaffold(
      title: title,
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              '${widget.driverName} (ID: ${widget.driverId})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!),
              )
            else if (_rows.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  widget.showCredits
                      ? 'No credited transactions found.'
                      : 'No deducted transactions found.',
                ),
              )
            else
              ..._rows.map(_rowTile),
          ],
        ),
      ),
    );
  }

  Widget _rowTile(Map<String, dynamic> row) {
    final amount = _toDouble(row['amount']);
    final date = _dateText(row['date']);
    final desc = row['description']?.toString() ?? '';
    final status = row['status']?.toString() ?? '-';
    final txnId = row['transaction_id']?.toString() ?? '-';
    final positive = widget.showCredits;
    final color = positive ? const Color(0xFF1B8E3E) : const Color(0xFFD93045);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$txnId • ${positive ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc.isEmpty ? 'Wallet transaction' : desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 2),
              Text(date, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  String _dateText(dynamic v) {
    final raw = v?.toString() ?? '';
    if (raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd MMM, hh:mm a').format(dt.toLocal());
  }
}
