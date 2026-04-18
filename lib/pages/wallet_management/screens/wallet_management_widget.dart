import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_scaffold.dart';
import '/components/skeleton_block.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/cache_service.dart';
import '/services/cache_policy.dart';

import '../widgets/action_buttons.dart';
import 'driver_wallet_detail_screen.dart';
import '../widgets/filters_bar.dart';
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
  static const String _cacheKey = CachePolicy.walletKey;
  static const Duration _cacheTtl = CachePolicy.walletTtl;
  static final _moneyFmt = NumberFormat('#,##0.00', 'en_IN');
  static final _moneyIntFmt = NumberFormat('#,##0', 'en_IN');
  static const int _txPageSize = 20;

  bool isLoading = false;
  bool isBackgroundRefreshing = false;
  bool txLoading = false;
  String? loadError;
  DateTime? _lastUpdatedAt;

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> withdraws = [];

  int _txPage = 1;
  int _txTotal = 0;

  String totalBalanceLabel = '0';
  String totalCreditedLabel = '0';
  String totalDebitedLabel = '0';
  String pendingWithdrawalsLabel = '0';
  int pendingWithdrawalsCount = 0;

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
  Future<void>? _inFlightFetch;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadCachedPreview();
    final age = await CacheService.getCacheAge(_cacheKey);
    final shouldRefresh = age == null || age > _cacheTtl || !_hasPreviewData();
    if (shouldRefresh) {
      await fetchData(backgroundRefresh: true);
    }
  }

  Future<void> fetchData({bool backgroundRefresh = false}) async {
    if (_inFlightFetch != null) {
      return _inFlightFetch;
    }
    _inFlightFetch =
        _fetchDataInternal(backgroundRefresh: backgroundRefresh);
    try {
      await _inFlightFetch;
    } finally {
      _inFlightFetch = null;
    }
  }

  Future<void> _fetchDataInternal({bool backgroundRefresh = false}) async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        isBackgroundRefreshing = false;
        loadError = 'Not signed in';
      });
      return;
    }

    final hasPreview = _hasPreviewData();
    setState(() {
      isLoading = !hasPreview && !backgroundRefresh;
      isBackgroundRefreshing = hasPreview || backgroundRefresh;
      loadError = null;
    });

    try {
      _txPage = 1;
      final results = await Future.wait([
        GetAdminWalletSummaryCall.call(token: token),
        CompanyWalletCall.call(token: token),
        GetWalletsCall.call(token: token),
        GetDriversCall.call(token: token),
        GetAdminWithdrawRequestsCall.call(token: token),
      ]);

      if (!mounted) return;

      final summaryResp = results[0];
      final companyResp = results[1];
      final walletsResp = results[2];
      final driversResp = results[3];
      final withdrawReqResp = results[4];

      final errs = <String>[];
      if (!summaryResp.succeeded) {
        errs.add('Wallet summary (${summaryResp.statusCode})');
      }
      if (!companyResp.succeeded && !summaryResp.succeeded) {
        errs.add('Company wallet (${companyResp.statusCode})');
      }
      if (!walletsResp.succeeded) {
        errs.add('Wallets (${walletsResp.statusCode})');
      }
      if (!driversResp.succeeded) {
        errs.add('Drivers (${driversResp.statusCode})');
      }
      if (!withdrawReqResp.succeeded) {
        errs.add('Withdraw requests (${withdrawReqResp.statusCode})');
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

      if (summaryResp.succeeded) {
        _applyWalletSummaryResponse(summaryResp);
      } else {
        _applyWalletAggregates(walletRows, companyResp);
      }

      var payoutRows = <Map<String, dynamic>>[];
      if (withdrawReqResp.succeeded) {
        payoutRows = GetAdminWithdrawRequestsCall.requestsList(
          withdrawReqResp.jsonBody,
        ).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        final fallback = await GetAdminPendingPayoutsCall.call(
          token: token,
          page: 1,
          limit: 100,
          status: 'all',
          includeStatusParam: true,
        );
        if (fallback.succeeded) {
          payoutRows = GetAdminPendingPayoutsCall.payoutsList(fallback.jsonBody)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      withdraws = payoutRows.map(_payoutToWithdrawRow).toList();
      _applyPendingWithdrawTotal(payoutRows);

      await _fetchTransactionPage(1, showTableSpinner: false);
      await _persistCache();

      if (!mounted) return;
      setState(() {
        isLoading = false;
        isBackgroundRefreshing = false;
        loadError = errs.isEmpty ? null : 'Some data failed: ${errs.join(', ')}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isBackgroundRefreshing = false;
        loadError = _hasPreviewData() ? 'Showing last updated data' : e.toString();
      });
      if (_hasPreviewData()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Showing last updated data')),
        );
      }
    }
  }

  bool _hasPreviewData() {
    return transactions.isNotEmpty ||
        withdraws.isNotEmpty ||
        totalBalanceLabel != '0' ||
        totalCreditedLabel != '0' ||
        totalDebitedLabel != '0';
  }

  Future<void> _loadCachedPreview() async {
    final cached = await CacheService.getData(_cacheKey);
    final ts = await CacheService.getLastUpdated(_cacheKey);
    if (!mounted || cached == null) return;
    setState(() {
      transactions = _toMapList(cached['transactions']);
      withdraws = _toMapList(cached['withdraws']);
      totalBalanceLabel = cached['totalBalanceLabel']?.toString() ?? totalBalanceLabel;
      totalCreditedLabel =
          cached['totalCreditedLabel']?.toString() ?? totalCreditedLabel;
      totalDebitedLabel = cached['totalDebitedLabel']?.toString() ?? totalDebitedLabel;
      pendingWithdrawalsLabel =
          cached['pendingWithdrawalsLabel']?.toString() ?? pendingWithdrawalsLabel;
      pendingWithdrawalsCount = _parseInt(cached['pendingWithdrawalsCount']) ?? 0;
      topDriverName = cached['topDriverName']?.toString();
      topDriverBalance = cached['topDriverBalance']?.toString();
      _lastUpdatedAt = ts;
      isLoading = false;
      loadError = null;
    });
  }

  Future<void> _persistCache() async {
    await CacheService.saveData(_cacheKey, {
      'transactions': transactions,
      'withdraws': withdraws,
      'totalBalanceLabel': totalBalanceLabel,
      'totalCreditedLabel': totalCreditedLabel,
      'totalDebitedLabel': totalDebitedLabel,
      'pendingWithdrawalsLabel': pendingWithdrawalsLabel,
      'pendingWithdrawalsCount': pendingWithdrawalsCount,
      'topDriverName': topDriverName,
      'topDriverBalance': topDriverBalance,
    });
    _lastUpdatedAt = await CacheService.getLastUpdated(_cacheKey);
  }

  List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
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
      String? fromIso;
      String? toIso;
      if (_selectedDateRange != null) {
        final s = _selectedDateRange!.start;
        final e = _selectedDateRange!.end;
        fromIso =
            '${s.year.toString().padLeft(4, '0')}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}';
        toIso =
            '${e.year.toString().padLeft(4, '0')}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}';
      }
      final resp = await GetAdminWalletTransactionsCall.call(
        token: token,
        page: page,
        limit: _txPageSize,
        q: search.trim().isEmpty ? null : search.trim(),
        flow: typeFilter == 'all' ? null : typeFilter,
        driverId: _selectedDriverId,
        from: fromIso,
        to: toIso,
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

      final raw = GetAdminWalletTransactionsCall.transactionsList(resp.jsonBody)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(_normalizeAdminWalletTransaction)
          .toList();
      final total = GetAdminWalletTransactionsCall.total(resp.jsonBody);
      setState(() {
        _txPage = page;
        _txTotal = total;
        transactions = raw;
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

  Map<String, dynamic> _normalizeAdminWalletTransaction(Map<String, dynamic> row) {
    final driver = row['driver'] is Map
        ? Map<String, dynamic>.from(row['driver'] as Map)
        : const <String, dynamic>{};
    final type = (row['type']?.toString() ?? '').toLowerCase();
    final flow = type.contains('debit') || type.contains('withdrawal') ? 'debit' : 'credit';
    final amount = _parseDouble(row['amount']) ?? 0;
    final balance = _parseDouble(row['balance']) ??
        _parseDouble(row['balance_after']) ??
        0;
    return <String, dynamic>{
      ...row,
      'transaction_id_display': row['txn_id']?.toString() ??
          row['transaction_id']?.toString() ??
          '#TXN${row['id'] ?? ''}',
      'party_name': driver['name']?.toString() ?? row['party_name']?.toString() ?? 'Driver',
      'party_phone': driver['mobile']?.toString() ?? row['party_phone']?.toString() ?? '',
      'driver_id': _parseInt(driver['id']) ?? _parseInt(row['driver_id']),
      'flow': flow,
      'amount': amount,
      'description': row['description']?.toString() ?? 'Wallet transaction',
      'created_at': row['date']?.toString() ?? row['created_at']?.toString() ?? '',
      'balance_after': balance,
      'status': row['status']?.toString() ?? 'completed',
    };
  }

  void _onSearchChanged(String value) {
    setState(() => search = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _fetchTransactionPage(1, showTableSpinner: true);
    });
  }

  void _onTopBarViewTap() {
    _searchDebounce?.cancel();
    final q = search.trim();
    if (q.isNotEmpty) {
      final matches = _findDriversByQuery(q);
      if (matches.isNotEmpty) {
        if (matches.length == 1) {
          _openDriverWalletDetail(driver: matches.first);
        } else {
          _showDriverPicker(matches);
        }
        return;
      }
    }
    _fetchTransactionPage(1, showTableSpinner: true);
  }

  void _showTransactionDetail(Map<String, dynamic> row) {
    setState(() {
      _selectedTransaction = row;
      final resolved = _driverIdFromTransactionRow(row);
      if (resolved != null) {
        _selectedDriverId = resolved;
      }
    });

    final driverId = _driverIdFromTransactionRow(row);
    if (driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver id not available for this row.')),
      );
      return;
    }
    final driver = _drivers.cast<Map<String, dynamic>?>().firstWhere(
          (d) => _parseInt(d?['id']) == driverId,
          orElse: () => null,
        );
    _openDriverWalletDetail(driverId: driverId, driver: driver, row: row);
  }

  List<Map<String, dynamic>> _findDriversByQuery(String raw) {
    final query = raw.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final queryId = int.tryParse(query);
    final compactQuery = query.replaceAll(' ', '');

    int score(Map<String, dynamic> d) {
      final id = _parseInt(d['id']);
      final first = (d['first_name']?.toString() ?? '').trim();
      final last = (d['last_name']?.toString() ?? '').trim();
      final full = '$first $last'.trim().toLowerCase();
      final phone = ((d['mobile'] ?? d['mobile_number'])?.toString() ?? '')
          .replaceAll(' ', '')
          .toLowerCase();
      if (queryId != null && id == queryId) return 100;
      if (full == query) return 90;
      if (full.startsWith(query)) return 80;
      if (full.contains(query)) return 70;
      if (phone == compactQuery) return 60;
      if (phone.endsWith(compactQuery)) return 50;
      if (phone.contains(compactQuery)) return 40;
      return -1;
    }

    final scored = <Map<String, dynamic>>[];
    for (final d in _drivers) {
      final s = score(d);
      if (s < 0) continue;
      scored.add({
        'driver': d,
        'score': s,
      });
    }
    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return scored
        .map((e) => Map<String, dynamic>.from(e['driver'] as Map))
        .toList();
  }

  void _showDriverPicker(List<Map<String, dynamic>> matches) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Select driver (${matches.length} matches)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final d = matches[index];
                      final id = _parseInt(d['id']);
                      final first = (d['first_name']?.toString() ?? '').trim();
                      final last = (d['last_name']?.toString() ?? '').trim();
                      final full = '$first $last'.trim();
                      final name = full.isNotEmpty ? full : 'Driver #${id ?? ''}';
                      final phone = (d['mobile'] ?? d['mobile_number'] ?? '-').toString();
                      return ListTile(
                        title: Text(name),
                        subtitle: Text('$phone · ID: ${id ?? '-'}'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pop(ctx);
                          _openDriverWalletDetail(driver: d);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int? _driverIdFromTransactionRow(Map<String, dynamic> row) {
    return _parseInt(row['driver_id']) ??
        _parseInt(row['party_id']) ??
        _parseInt(row['user_id']);
  }

  void _openDriverWalletDetail({
    required Map<String, dynamic>? driver,
    Map<String, dynamic>? row,
    int? driverId,
  }) {
    final resolvedId = driverId ??
        _parseInt(driver?['id']) ??
        _driverIdFromTransactionRow(row ?? const {});
    if (resolvedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching driver found for this search.')),
      );
      return;
    }

    final name = (('${driver?['first_name'] ?? ''} ${driver?['last_name'] ?? ''}').trim().isNotEmpty)
        ? '${driver?['first_name'] ?? ''} ${driver?['last_name'] ?? ''}'.trim()
        : (row?['party_name']?.toString() ?? 'Driver #$resolvedId');
    final phone = driver?['mobile']?.toString() ??
        driver?['mobile_number']?.toString() ??
        row?['party_phone']?.toString() ??
        '-';
    final balance = _moneyFmt.format(
      _parseDouble(driver?['wallet_balance']) ??
          _parseDouble(row?['balance_after']) ??
          0,
    );
    final totalRides = _parseInt(driver?['total_rides']) ??
        _parseInt(driver?['ride_count']) ??
        _parseInt(driver?['completed_rides']) ??
        0;
    final totalEarnings = _moneyFmt.format(_parseDouble(driver?['total_earnings']) ?? 0);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverWalletDetailScreen(
          driverId: resolvedId,
          driverName: name,
          phone: phone,
          balance: balance,
          totalRides: totalRides,
          totalEarnings: totalEarnings,
          avatarUrl: driver?['profile_image']?.toString(),
        ),
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

  void _applyWalletSummaryResponse(ApiCallResponse response) {
    final data = GetAdminWalletSummaryCall.data(response.jsonBody);
    if (data == null) return;

    totalBalanceLabel = _moneyIntFmt.format(_parseDouble(data['total_wallet_balance']) ?? 0);
    totalCreditedLabel = _moneyIntFmt.format(_parseDouble(data['total_credited']) ?? 0);
    totalDebitedLabel = _moneyIntFmt.format(_parseDouble(data['total_debited']) ?? 0);
    pendingWithdrawalsLabel =
        _moneyIntFmt.format(_parseDouble(data['pending_withdrawals_amount']) ?? 0);
    pendingWithdrawalsCount = _parseInt(data['pending_withdrawals_count']) ?? 0;
  }

  void _applyPendingWithdrawTotal(List<Map<String, dynamic>> payoutRows) {
    double pending = 0;
    for (final p in payoutRows) {
      final raw = _parseDouble(p['amount_raw']) ?? _parseDouble(p['amount']);
      final s = (p['status']?.toString() ?? '').toLowerCase();
      if (raw == null) continue;
      if (s.contains('paid') || s.contains('complete')) continue;
      if (s.contains('fail') || s.contains('reject')) continue;
      if (s.contains('pending') || s == 'processing') {
        pending += raw;
      }
    }
    pendingWithdrawalsLabel = _moneyIntFmt.format(pending);
    pendingWithdrawalsCount = payoutRows.length;
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
    final driver = p['driver'] is Map ? Map<String, dynamic>.from(p['driver']) : null;
    final raw = _parseDouble(p['amount_raw']) ?? _parseDouble(p['amount']);
    final amountStr = raw != null
        ? _moneyFmt.format(raw)
        : (p['amount']?.toString().replaceAll('₹', '').trim() ?? '0');
    final name = p['driver_name']?.toString().trim().isNotEmpty == true
        ? p['driver_name'].toString().trim()
        : (driver?['name']?.toString().trim().isNotEmpty == true
            ? driver!['name'].toString().trim()
            : 'Driver #${p['driver_id'] ?? driver?['id'] ?? ''}');
    final phone = p['mobile']?.toString() ??
        p['phone']?.toString() ??
        driver?['mobile']?.toString() ??
        '';
    final status = p['status']?.toString() ?? 'pending_manual_transfer';
    final req = p['request_date'] ?? p['requested_date'] ?? p['created_at'];
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
      'wr_id': p['wr_id']?.toString(),
      'driver_name': name,
      'phone': phone,
      'amount': amountStr,
      'amount_raw': raw,
      'upi_or_bank': p['upi_or_bank']?.toString(),
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

  Future<void> _promptWalletAdjust({required bool credit}) async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    final driverIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final idemCtrl = TextEditingController(
      text: 'admin-${DateTime.now().millisecondsSinceEpoch}',
    );
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(credit ? 'Credit driver wallet' : 'Debit driver wallet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: driverIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Driver ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: credit ? 'Amount (INR)' : 'Amount (INR, positive number)',
                    border: const OutlineInputBorder(),
                    helperText: credit ? null : 'Will be applied as a negative ledger entry.',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: idemCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Idempotency key',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      final did = int.tryParse(driverIdCtrl.text.trim());
      final rawAmt = double.tryParse(amountCtrl.text.trim());
      final reason = reasonCtrl.text.trim();
      final idem = idemCtrl.text.trim();
      if (did == null || did <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valid driver ID required.')),
        );
        return;
      }
      if (rawAmt == null || rawAmt <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valid positive amount required.')),
        );
        return;
      }
      if (reason.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reason must be at least 3 characters.')),
        );
        return;
      }
      if (idem.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Idempotency key must be at least 8 characters.')),
        );
        return;
      }
      final signed = credit ? rawAmt : -rawAmt;
      final resp = await PostAdminWalletAdjustCall.call(
        token: token,
        driverId: did,
        amount: signed,
        reason: reason,
        idempotencyKey: idem,
      );
      if (!mounted) return;
      if (!resp.succeeded) {
        final msg = getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
            'Adjust failed (${resp.statusCode})';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wallet adjustment applied.')),
      );
      await fetchData(backgroundRefresh: true);
    } finally {
      driverIdCtrl.dispose();
      amountCtrl.dispose();
      reasonCtrl.dispose();
      idemCtrl.dispose();
    }
  }

  void addMoney() {
    unawaited(_promptWalletAdjust(credit: true));
  }

  void deductMoney() {
    unawaited(_promptWalletAdjust(credit: false));
  }

  void adjustCommission() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use Fare & finance settings for commission %; wallet row is for driver balance.'),
      ),
    );
  }

  Future<void> _exportWalletSnapshot() async {
    final rows = <String>[
      'section,label,value',
      'summary,Total Wallet,"$totalBalanceLabel"',
      'summary,Total Credited,"$totalCreditedLabel"',
      'summary,Total Debited,"$totalDebitedLabel"',
      'summary,Pending Withdrawals,"$pendingWithdrawalsLabel"',
    ];

    for (final tx in transactions) {
      final id = tx['transaction_id_display']?.toString() ?? tx['id']?.toString() ?? '';
      final flow = tx['flow']?.toString() ?? '';
      final amount = tx['amount']?.toString() ?? '';
      final desc = tx['description']?.toString().replaceAll('"', "'") ?? '';
      rows.add('transaction,"$id","$flow ₹$amount - $desc"');
    }

    await Clipboard.setData(ClipboardData(text: rows.join('\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet snapshot copied as CSV to clipboard.')),
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

  Future<void> rejectWithdraw(int? id) async {
    if (id == null) return;
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    final reasonCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Reject payout #$id'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Provide a short reason (required).'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      final reason = reasonCtrl.text.trim();
      if (reason.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reason must be at least 3 characters.')),
        );
        return;
      }
      final resp = await PostAdminPayoutRejectCall.call(
        token: token,
        payoutId: id,
        reason: reason,
      );
      if (!mounted) return;
      if (!resp.succeeded) {
        final msg = getJsonField(resp.jsonBody, r'''$.message''')?.toString() ??
            'Reject failed (${resp.statusCode})';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout rejected.')),
      );
      await fetchData(backgroundRefresh: true);
    } finally {
      reasonCtrl.dispose();
    }
  }

  // ignore: unused_element
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


  Widget _buildSummaryAndExport() {
    Widget exportBtn({bool compact = false}) {
      return FilledButton.icon(
        onPressed: _exportWalletSnapshot,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF7C948),
          foregroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          minimumSize: Size(compact ? 110 : 128, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.download_rounded, size: 18),
        label: const Text(
          'Export',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 920;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WalletSummaryCards(
                totalBalance: totalBalanceLabel,
                totalCredited: totalCreditedLabel,
                totalDebited: totalDebitedLabel,
                pendingWithdrawals: pendingWithdrawalsLabel,
                pendingWithdrawalsCount: pendingWithdrawalsCount,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: exportBtn(compact: true),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: WalletSummaryCards(
                totalBalance: totalBalanceLabel,
                totalCredited: totalCreditedLabel,
                totalDebited: totalDebitedLabel,
                pendingWithdrawals: pendingWithdrawalsLabel,
                pendingWithdrawalsCount: pendingWithdrawalsCount,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: exportBtn(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Wallet Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: (isLoading || txLoading || isBackgroundRefreshing)
              ? null
              : () => fetchData(backgroundRefresh: true),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => fetchData(backgroundRefresh: true),
        child: isLoading && !_hasPreviewData()
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: const [
                  SkeletonBlock(width: double.infinity, height: 110, radius: 14),
                  SizedBox(height: 12),
                  SkeletonBlock(width: double.infinity, height: 64, radius: 12),
                  SizedBox(height: 12),
                  SkeletonBlock(width: double.infinity, height: 320, radius: 12),
                ],
              )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isBackgroundRefreshing)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (_lastUpdatedAt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Updated ${dateTimeFormat("relative", _lastUpdatedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _buildSummaryAndExport(),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: WalletActionsRow(
                  onAddMoney: addMoney,
                  onDeductMoney: deductMoney,
                  onAdjustCommission: adjustCommission,
                  initialSearch: search,
                  onSearchChanged: (value) => setState(() => search = value),
                  onViewTap: _onTopBarViewTap,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: WalletFiltersBar(
                  onSearch: _onSearchChanged,
                  initialSearch: search,
                  initialType: typeFilter,
                  initialDriverId: _selectedDriverId,
                  initialDateRange: _selectedDateRange,
                  drivers: _drivers,
                  onTypeChange: (value) {
                    setState(() => typeFilter = value);
                    _fetchTransactionPage(1, showTableSpinner: true);
                  },
                  onDriverChange: (driverId) {
                    setState(() => _selectedDriverId = driverId);
                    _fetchTransactionPage(1, showTableSpinner: true);
                  },
                  onDateRangeChange: (range) {
                    setState(() => _selectedDateRange = range);
                    _fetchTransactionPage(1, showTableSpinner: true);
                  },
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  return WalletTransactionList(
                    transactions: transactions,
                    isLoading: isLoading || txLoading,
                    page: _txPage,
                    pageSize: _txPageSize,
                    totalCount: _txTotal,
                    onPageChanged: (p) =>
                        _fetchTransactionPage(p, showTableSpinner: true),
                    onViewRow: _showTransactionDetail,
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
