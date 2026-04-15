import 'dart:async';

import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_scaffold.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '../widgets/action_buttons.dart';
import '../widgets/summary_cards.dart';
import '../widgets/transaction_list.dart';
import '../widgets/withdraw_list.dart';

class WalletManagementWidget extends StatefulWidget {
  const WalletManagementWidget({super.key});

  static String routeName = 'WalletManagement';
  static String routePath = '/wallet-management';

  @override
  State<WalletManagementWidget> createState() =>
      _WalletManagementWidgetState();
}

class _WalletManagementWidgetState extends State<WalletManagementWidget> {
  static final _moneyFmt = NumberFormat('#,##0.00', 'en_IN');
  static final _moneyIntFmt = NumberFormat('#,##0', 'en_IN');
  static const int _txPageSize = 10;

  bool isLoading = false;
  bool txLoading = false;
  String? loadError;

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> withdraws = [];

  int _txPage = 1;
  int _txTotal = 0;

  String totalBalanceLabel = '0';
  String totalCreditedLabel = '0';
  String totalDebitedLabel = '0';
  String pendingWithdrawalsLabel = '0';

  String? topDriverName;
  String? topDriverBalance;
  Map<String, dynamic>? _selectedTransaction;
  List<Map<String, dynamic>> _drivers = [];
  int? _selectedDriverId;
  DateTimeRange? _selectedDateRange;

  String search = '';
  String typeFilter = 'all';
  String statusFilter = 'all';

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        loadError = 'Not signed in';
      });
      return;
    }

    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      _txPage = 1;
      final results = await Future.wait([
        CompanyWalletCall.call(token: token),
        GetWalletsCall.call(token: token),
        GetDriversCall.call(token: token),
        GetAdminPendingPayoutsCall.call(
          token: token,
          page: 1,
          limit: 100,
          status: 'all',
          includeStatusParam: true,
        ),
      ]);

      if (!mounted) return;

      final companyResp = results[0];
      final walletsResp = results[1];
      final driversResp = results[2];
      final payoutsResp = results[3];

      final errs = <String>[];
      if (!companyResp.succeeded) {
        errs.add('Company wallet (${companyResp.statusCode})');
      }
      if (!walletsResp.succeeded) {
        errs.add('Wallets (${walletsResp.statusCode})');
      }
      if (!driversResp.succeeded) {
        errs.add('Drivers (${driversResp.statusCode})');
      }
      if (!payoutsResp.succeeded) {
        errs.add('Payouts (${payoutsResp.statusCode})');
      }

      final walletRows = walletsResp.succeeded
          ? GetWalletsCall.walletsList(walletsResp.jsonBody)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];
      _drivers = driversResp.succeeded
          ? (GetDriversCall.data(driversResp.jsonBody) ?? const [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      _applyWalletAggregates(walletRows, companyResp);

      final payoutRows = payoutsResp.succeeded
          ? GetAdminPendingPayoutsCall.payoutsList(payoutsResp.jsonBody)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      withdraws = payoutRows.map(_payoutToWithdrawRow).toList();
      _applyPendingWithdrawTotal(payoutRows);

      await _fetchTransactionPage(1, showTableSpinner: false);

      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = errs.isEmpty ? null : 'Some data failed: ${errs.join(', ')}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = e.toString();
      });
    }
  }

  Future<void> _fetchTransactionPage(
    int page, {
    required bool showTableSpinner,
  }) async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          transactions = [];
          _txTotal = 0;
          _txPage = 1;
        });
      }
      return;
    }

    if (showTableSpinner && mounted) {
      setState(() => txLoading = true);
    }

    try {
      final resp = await GetAdminWalletTransactionsCall.call(
        token: token,
        page: page,
        limit: _txPageSize,
        q: search.trim().isEmpty ? null : search.trim(),
        flow: typeFilter == 'all' ? null : typeFilter,
        driverId: _selectedDriverId,
        from: _selectedDateRange?.start.toUtc().toIso8601String(),
        to: _selectedDateRange?.end.toUtc().toIso8601String(),
      );

      if (!mounted) return;

      if (!resp.succeeded) {
        setState(() {
          transactions = [];
          _txTotal = 0;
          _txPage = page;
          if (showTableSpinner) txLoading = false;
        });
        return;
      }

      final raw =
          GetAdminWalletTransactionsCall.transactionsList(resp.jsonBody);
      setState(() {
        _txPage = page;
        _txTotal = GetAdminWalletTransactionsCall.total(resp.jsonBody);
        transactions = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        if (_selectedTransaction == null && transactions.isNotEmpty) {
          _selectedTransaction = transactions.first;
        }
        if (showTableSpinner) txLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          transactions = [];
          _txTotal = 0;
          if (showTableSpinner) txLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() => search = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _fetchTransactionPage(1, showTableSpinner: true);
    });
  }

  void _showTransactionDetail(Map<String, dynamic> row) {
    setState(() => _selectedTransaction = row);
    final buf = StringBuffer();
    for (final e in row.entries) {
      buf.writeln('${e.key}: ${e.value}');
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(row['transaction_id_display']?.toString() ?? 'Transaction'),
        content: SingleChildScrollView(
          child: SelectableText(buf.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _applyWalletAggregates(
    List<Map<String, dynamic>> walletRows,
    ApiCallResponse companyResp,
  ) {
    double sumBalance = 0;
    double sumRecharge = 0;
    double sumSpent = 0;
    Map<String, dynamic>? bestDriverWallet;
    double bestBal = -1;

    for (final w in walletRows) {
      final bal =
          _parseDouble(w['wallet_balance']) ?? _parseDouble(w['balance']) ?? 0;
      final cb = _parseDouble(w['cashback_balance']) ?? 0;
      sumBalance += bal + cb;
      sumRecharge += _parseDouble(w['total_recharge_amount']) ?? 0;
      sumSpent += _parseDouble(w['total_spent_amount']) ?? 0;

      final did = _parseInt(w['driver_id']);
      if (did != null && bal > bestBal) {
        bestBal = bal;
        bestDriverWallet = w;
      }
    }

    if (sumBalance <= 0 && companyResp.succeeded) {
      final pool = _companyPoolInr(companyResp.jsonBody);
      if (pool != null && pool > 0) {
        totalBalanceLabel = _moneyIntFmt.format(pool);
      } else {
        totalBalanceLabel = _moneyIntFmt.format(sumBalance);
      }
    } else {
      totalBalanceLabel = _moneyIntFmt.format(sumBalance);
    }

    totalCreditedLabel = _moneyIntFmt.format(sumRecharge);
    totalDebitedLabel = _moneyIntFmt.format(sumSpent);

    if (bestDriverWallet != null) {
      topDriverName = 'Driver #${_parseInt(bestDriverWallet['driver_id'])}';
      topDriverBalance = _moneyFmt.format(bestBal);
    } else {
      topDriverName = null;
      topDriverBalance = null;
    }
  }

  void _applyPendingWithdrawTotal(List<Map<String, dynamic>> payoutRows) {
    double pending = 0;
    for (final p in payoutRows) {
      final raw = _parseDouble(p['amount_raw']);
      final s = (p['status']?.toString() ?? '').toLowerCase();
      if (raw == null) continue;
      if (s.contains('paid') || s.contains('complete')) continue;
      if (s.contains('fail') || s.contains('reject')) continue;
      if (s.contains('pending') || s == 'processing') {
        pending += raw;
      }
    }
    pendingWithdrawalsLabel = _moneyIntFmt.format(pending);
  }

  double? _companyPoolInr(dynamic body) {
    final data = body is Map ? getJsonField(body, r'''$.data''') : null;
    final rider = _parseDouble(getJsonField(data ?? body, r'''$.rider_total'''));
    final driver = _parseDouble(getJsonField(data ?? body, r'''$.driver_total'''));
    final total = _parseDouble(getJsonField(data ?? body, r'''$.total''')) ??
        _parseDouble(getJsonField(data ?? body, r'''$.balance''')) ??
        _parseDouble(getJsonField(data ?? body, r'''$.company_balance'''));
    if (total != null) return total;
    if (rider != null || driver != null) return (rider ?? 0) + (driver ?? 0);
    return null;
  }

  Map<String, dynamic> _payoutToWithdrawRow(Map<String, dynamic> p) {
    final id = _parseInt(p['payout_id']) ?? _parseInt(p['id']);
    final raw = _parseDouble(p['amount_raw']);
    final amountStr = raw != null
        ? _moneyFmt.format(raw)
        : (p['amount']?.toString().replaceAll('₹', '').trim() ?? '0');
    final name = p['driver_name']?.toString().trim().isNotEmpty == true
        ? p['driver_name'].toString().trim()
        : 'Driver #${p['driver_id'] ?? ''}';
    final phone = p['mobile']?.toString() ?? p['phone']?.toString() ?? '';
    final status = p['status']?.toString() ?? 'pending_manual_transfer';
    final req = p['requested_date'] ?? p['created_at'];
    String dateStr = '';
    if (req != null) {
      try {
        final d = DateTime.parse(req.toString());
        dateStr = DateFormat('d MMM yyyy, HH:mm').format(d.toLocal());
      } catch (_) {
        dateStr = req.toString();
      }
    }

    return {
      'id': id,
      'driver_name': name,
      'phone': phone,
      'amount': amountStr,
      'status': status,
      'date': dateStr,
    };
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString().trim());
  }

  void addMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Credit a rider from User details or wallet tools. Bulk add is not on this screen.',
        ),
      ),
    );
  }

  void deductMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Use driver payouts and ride settlement flows to debit wallets.',
        ),
      ),
    );
  }

  void adjustCommission() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Commission and finance settings use Admin Finance APIs when added to the app.',
        ),
      ),
    );
  }

  Future<void> approveWithdraw(int? id) async {
    if (id == null) return;
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;

    final refCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mark payout paid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payout #$id — after you complete the bank transfer, confirm here.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Payment reference (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;

      final resp = await MarkPayoutPaidCall.call(
        token: token,
        payoutId: id,
        paymentReference:
            refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
      );

      if (!mounted) return;
      if (!resp.succeeded) {
        final msg = getJsonField(resp.jsonBody, r'''$.message''')
                ?.toString() ??
            'Request failed (${resp.statusCode})';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout marked as paid.')),
      );
      await fetchData();
    } finally {
      refCtrl.dispose();
    }
  }

  void rejectWithdraw(int? id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          id != null
              ? 'Payout #$id: rejection is not exposed in the API. Use backend support if needed.'
              : 'Cannot reject: missing payout id.',
        ),
      ),
    );
  }

  Widget _buildTransactionToolbar() {
    InputDecoration dec(String hint, {Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        suffixIcon: suffixIcon,
      );
    }

    String driverLabel(Map<String, dynamic> d) {
      final fn = d['first_name']?.toString().trim() ?? '';
      final ln = d['last_name']?.toString().trim() ?? '';
      final full = '$fn $ln'.trim();
      if (full.isNotEmpty) return full;
      return 'Driver #${d['id'] ?? ''}';
    }

    String dateLabel() {
      if (_selectedDateRange == null) return 'Last 30 days';
      final s = DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start);
      final e = DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end);
      return '$s - $e';
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 240,
          child: TextField(
            readOnly: true,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 1),
                initialDateRange: _selectedDateRange,
              );
              if (picked == null) return;
              setState(() => _selectedDateRange = picked);
              _fetchTransactionPage(1, showTableSpinner: true);
            },
            decoration: dec(
              dateLabel(),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
            initialValue: typeFilter,
            decoration: dec('All Types'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Types')),
              DropdownMenuItem(value: 'credit', child: Text('Credit')),
              DropdownMenuItem(value: 'debit', child: Text('Debit')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => typeFilter = v);
              _fetchTransactionPage(1, showTableSpinner: true);
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<int?>(
            initialValue: _selectedDriverId,
            isExpanded: true,
            decoration: dec('All Drivers'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text(
                  'All Drivers',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ..._drivers.map(
                (d) => DropdownMenuItem<int?>(
                  value: _parseInt(d['id']),
                  child: Text(
                    driverLabel(d),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (v) {
              setState(() => _selectedDriverId = v);
              _fetchTransactionPage(1, showTableSpinner: true);
            },
          ),
        ),
        SizedBox(
          width: 240,
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: dec(
              'Search transactions...',
              suffixIcon: const Icon(Icons.search, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightDetailsPanel() {
    final tx = _selectedTransaction;
    final name = tx?['party_name']?.toString() ?? topDriverName ?? '—';
    final phone = tx?['party_phone']?.toString() ?? '—';
    final bal = tx?['balance_after'];
    final balNum = bal is num ? bal.toDouble() : _parseDouble(bal) ?? 0;
    final flow = tx?['flow']?.toString() ?? 'credit';
    final amount = _parseDouble(tx?['amount']) ?? 0;
    final recent = transactions.take(5).toList();

    Color activityColor(String f) =>
        f.toLowerCase() == 'debit' ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Driver Wallet Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(phone, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 10),
          Text(
            'Wallet Balance: ₹${_moneyFmt.format(balNum)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: addMoney,
                  child: const Text('Add Money'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: deductMoney,
                  child: const Text('Deduct'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Text('No activity', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ...recent.map((r) {
            final f = r['flow']?.toString() ?? 'credit';
            final c = activityColor(f);
            final amt = _parseDouble(r['amount']) ?? 0;
            final desc = r['description']?.toString() ?? 'Transaction';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    f == 'debit' ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: c,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${f == 'debit' ? '-' : '+'}₹${_moneyFmt.format(amt)}',
                          style: TextStyle(
                            color: c,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Text(
            'Selected: ${flow.toUpperCase()} ₹${_moneyFmt.format(amount)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Wallet Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: (isLoading || txLoading) ? null : fetchData,
        ),
      ],
      child: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loadError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        loadError!,
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ),
                ),
              WalletSummaryCards(
                totalBalance: totalBalanceLabel,
                totalCredited: totalCreditedLabel,
                totalDebited: totalDebitedLabel,
                pendingWithdrawals: pendingWithdrawalsLabel,
              ),
              const SizedBox(height: 12),
              WalletActionsRow(
                onAddMoney: addMoney,
                onDeductMoney: deductMoney,
                onAdjustCommission: adjustCommission,
              ),
              const SizedBox(height: 12),
              _buildTransactionToolbar(),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1200;
                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WalletTransactionList(
                          transactions: transactions,
                          isLoading: isLoading || txLoading,
                          page: _txPage,
                          pageSize: _txPageSize,
                          totalCount: _txTotal,
                          onPageChanged: (p) =>
                              _fetchTransactionPage(p, showTableSpinner: true),
                          onViewRow: _showTransactionDetail,
                        ),
                        const SizedBox(height: 12),
                        _buildRightDetailsPanel(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: WalletTransactionList(
                          transactions: transactions,
                          isLoading: isLoading || txLoading,
                          page: _txPage,
                          pageSize: _txPageSize,
                          totalCount: _txTotal,
                          onPageChanged: (p) =>
                              _fetchTransactionPage(p, showTableSpinner: true),
                          onViewRow: _showTransactionDetail,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 320,
                        child: _buildRightDetailsPanel(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Withdraw Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${withdraws.length} pending)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              WithdrawRequestList(
                withdraws: withdraws,
                isLoading: isLoading,
                onRefresh: fetchData,
                onApprove: (w) => approveWithdraw(_parseInt(w['id'])),
                onReject: (w) => rejectWithdraw(_parseInt(w['id'])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
