import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_drawer.dart';
import '/config/theme/flutter_flow_theme.dart';

class WalletTransactionsScreen extends ConsumerStatefulWidget {
  const WalletTransactionsScreen({super.key});

  static String routeName = 'WalletTransactionsScreen';
  static String routePath = '/wallet-transactions';

  @override
  ConsumerState<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState
    extends ConsumerState<WalletTransactionsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  String? _error;
  int _page = 1;
  int _total = 0;
  static const int _pageSize = 20;

  String _search = '';
  String _typeFilter = 'all'; // 'all' | 'credit' | 'debit'
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await GetAdminWalletTransactionsCall.call(
        token: currentAuthenticationToken,
        page: page,
        limit: _pageSize,
        q: _search.trim().isEmpty ? null : _search.trim(),
        flow: _typeFilter == 'all' ? null : _typeFilter,
      );
      if (!mounted) return;
      if (!res.succeeded) {
        setState(() {
          _loading = false;
          _error =
              'Failed to load transactions (${res.statusCode}). Please retry.';
        });
        return;
      }
      final raw = GetAdminWalletTransactionsCall.transactionsList(res.jsonBody)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      setState(() {
        _transactions = raw;
        _total = GetAdminWalletTransactionsCall.total(res.jsonBody);
        _page = page;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _loadPage(1);
    });
  }

  void _onTypeFilterChanged(String value) {
    setState(() => _typeFilter = value);
    _loadPage(1);
  }

  int get _totalPages => (_total / _pageSize).ceil().clamp(1, 999);

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminPopScope(
      child: Scaffold(
        key: scaffoldKey,
        drawer: buildAdminDrawer(context),
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          centerTitle: true,
          title: Text(
            'Wallet Transactions',
            style: theme.headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : () => _loadPage(_page),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Filters ──────────────────────────────────────────────
            Container(
              color: theme.secondaryBackground,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search driver name or Txn ID...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: theme.primaryBackground,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'All',
                    selected: _typeFilter == 'all',
                    onTap: () => _onTypeFilterChanged('all'),
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Credit',
                    selected: _typeFilter == 'credit',
                    color: const Color(0xFF2E7D32),
                    onTap: () => _onTypeFilterChanged('credit'),
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Debit',
                    selected: _typeFilter == 'debit',
                    color: const Color(0xFFC62828),
                    onTap: () => _onTypeFilterChanged('debit'),
                    theme: theme,
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: theme.primary))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 48, color: theme.error),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  textAlign: TextAlign.center,
                                  style: theme.bodyMedium
                                      .override(color: theme.secondaryText)),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _loadPage(_page),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _transactions.isEmpty
                          ? Center(
                              child: Text(
                                'No transactions found',
                                style: theme.bodyMedium
                                    .override(color: theme.secondaryText),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 10, 12, 8),
                              itemCount: _transactions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final tx = _transactions[i];
                                final driver = tx['driver'] is Map
                                    ? Map<String, dynamic>.from(
                                        tx['driver'] as Map)
                                    : <String, dynamic>{};
                                final driverName =
                                    driver['name']?.toString() ?? 'Unknown';
                                final driverPhone =
                                    driver['mobile']?.toString() ?? '';
                                final txnId = tx['txn_id']?.toString() ??
                                    '#TXN${tx['id']}';
                                final type =
                                    (tx['type']?.toString() ?? '').toLowerCase();
                                final isCredit =
                                    type.contains('credit') ||
                                        type.contains('recharge') ||
                                        type.contains('bonus');
                                final amount = _toDouble(tx['amount']);
                                final balance = _toDouble(tx['balance']);
                                final description =
                                    tx['description']?.toString() ??
                                        'Wallet transaction';
                                final date = _formatDate(
                                    tx['date']?.toString() ??
                                        tx['created_at']?.toString());
                                final typeColor = isCredit
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828);

                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.secondaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: theme.alternate),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Type icon
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: typeColor.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isCredit
                                                ? Icons.arrow_downward_rounded
                                                : Icons.arrow_upward_rounded,
                                            color: typeColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    txnId,
                                                    style: theme.labelMedium
                                                        .override(
                                                      font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                      color: theme.primaryText,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: typeColor
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      isCredit
                                                          ? 'Credit'
                                                          : 'Debit',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: typeColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                description,
                                                style: theme.bodySmall.override(
                                                    color: theme.primaryText),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                driverPhone.isNotEmpty
                                                    ? '$driverName · $driverPhone'
                                                    : driverName,
                                                style: theme.labelSmall.override(
                                                  font: GoogleFonts.inter(),
                                                  color: theme.secondaryText,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                date,
                                                style: theme.labelSmall.override(
                                                  font: GoogleFonts.inter(),
                                                  color: theme.secondaryText,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Amounts
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                                              style: theme.titleMedium.override(
                                                font: GoogleFonts.interTight(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                color: typeColor,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Bal ₹${balance.toStringAsFixed(2)}',
                                              style: theme.labelSmall.override(
                                                font: GoogleFonts.inter(),
                                                color: theme.secondaryText,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            // ── Pagination ────────────────────────────────────────────
            if (!_loading && _error == null && _total > 0)
              Container(
                color: theme.secondaryBackground,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Showing ${((_page - 1) * _pageSize) + 1}–${(_page * _pageSize).clamp(1, _total)} of $_total',
                      style: theme.labelSmall
                          .override(color: theme.secondaryText, fontSize: 12),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _page > 1
                          ? () => _loadPage(_page - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                      iconSize: 22,
                    ),
                    Text(
                      '$_page / $_totalPages',
                      style: theme.labelMedium,
                    ),
                    IconButton(
                      onPressed: _page < _totalPages
                          ? () => _loadPage(_page + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                      iconSize: 22,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final FlutterFlowTheme theme;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? theme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.12)
              : theme.primaryBackground,
          border: Border.all(
            color: selected ? activeColor : theme.alternate,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? activeColor : theme.secondaryText,
          ),
        ),
      ),
    );
  }
}
