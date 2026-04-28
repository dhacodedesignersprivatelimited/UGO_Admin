import 'package:flutter/material.dart';
import 'dart:math' as math;

class WalletTransactionList extends StatelessWidget {
  const WalletTransactionList({
    super.key,
    required this.transactions,
    required this.isLoading,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
    this.onViewRow,
  });

  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int> onPageChanged;
  final void Function(Map<String, dynamic> row)? onViewRow;

  int get totalPages {
    if (totalCount <= 0) return 1;
    final pages = (totalCount / pageSize).ceil();
    return pages <= 0 ? 1 : pages;
  }

  @override
  Widget build(BuildContext context) {
    final start = totalCount == 0 ? 0 : ((page - 1) * pageSize) + 1;
    final end = totalCount == 0 ? 0 : (page * pageSize).clamp(1, totalCount);

    const tableMinW = 1024.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Text(
                  'Wallet Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                Text(
                  'Showing $start to $end of $totalCount transactions',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final contentW = math.max(tableMinW, constraints.maxWidth);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentW,
                    child: _TransactionDataTable(
                      rows: transactions,
                      onViewRow: onViewRow,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PaginationBar(
              page: page,
              totalPages: totalPages,
              onPageChanged: onPageChanged,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _TransactionDataTable extends StatelessWidget {
  const _TransactionDataTable({
    required this.rows,
    required this.onViewRow,
  });

  final List<Map<String, dynamic>> rows;
  final void Function(Map<String, dynamic> row)? onViewRow;

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade700,
      letterSpacing: 0.2,
    );
    // Adjusted column widths for better fit
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text('Txn ID', style: headerStyle)),
                SizedBox(width: 120, child: Text('Driver', style: headerStyle)),
                SizedBox(width: 70, child: Text('Type', style: headerStyle)),
                SizedBox(width: 90, child: Text('Amount', style: headerStyle)),
                SizedBox(width: 90, child: Text('Balance', style: headerStyle)),
                SizedBox(width: 80, child: Text('Status', style: headerStyle)),
                SizedBox(width: 100, child: Text('Date', style: headerStyle)),
                SizedBox(width: 80, child: Text('Action', style: headerStyle)),
              ],
            ),
          ),
        ),
        ...rows.map((r) {
          final flow = (r['flow']?.toString() ?? '').toLowerCase();
          final credit = flow == 'credit';
          final amount = _num(r['amount']);
          final balance = _num(r['balance_after']);
          final status = _statusLabel(r);
          final statusColor = _statusColor(status);
          final id = r['transaction_id_display']?.toString() ??
              r['transaction_id']?.toString() ??
              r['id']?.toString() ??
              '-';
          final user = r['party_name']?.toString() ?? '-';
          final created = _dateLabel(r['created_at']);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 80,
                    child: Text(id,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(
                  width: 120,
                  child: Text(
                    user,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    credit ? 'Credit' : 'Debit',
                    style: TextStyle(
                      color: credit
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    '${credit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: credit
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text('₹${balance.toStringAsFixed(2)}'),
                ),
                SizedBox(
                  width: 80,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    created,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined,
                            size: 18, color: Color(0xFF4A87C2)),
                        tooltip: 'View',
                        onPressed:
                            onViewRow == null ? null : () => onViewRow!(r),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String _statusLabel(Map<String, dynamic> r) {
    final status = (r['status']?.toString() ?? '').trim();
    if (status.isNotEmpty) return status;
    final flow = (r['flow']?.toString() ?? '').toLowerCase();
    if (flow == 'credit') return 'Success';
    if (flow == 'debit') return 'Completed';
    return 'Pending';
  }

  static Color _statusColor(String value) {
    final status = value.toLowerCase();
    if (status.contains('success') ||
        status.contains('complete') ||
        status.contains('paid')) {
      return const Color(0xFF2E7D32);
    }
    if (status.contains('pending') || status.contains('process')) {
      return const Color(0xFFEF6C00);
    }
    if (status.contains('fail') ||
        status.contains('reject') ||
        status.contains('error')) {
      return const Color(0xFFC62828);
    }
    return const Color(0xFF455A64);
  }

  static String _dateLabel(dynamic v) {
    final raw = v?.toString() ?? '';
    if (raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text('Page $page / $totalPages'),
        IconButton(
          onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
