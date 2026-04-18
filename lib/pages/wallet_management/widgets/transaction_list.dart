import 'package:flutter/material.dart';

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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Wallet Transactions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              Text(
                'Showing $start to $end of $totalCount transactions',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            )
          else
            _TransactionDataTable(
              rows: transactions,
              onViewRow: onViewRow,
            ),
          const SizedBox(height: 10),
          _PaginationBar(
            page: page,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 42,
          dataRowMinHeight: 44,
          dataRowMaxHeight: 52,
          horizontalMargin: 10,
          columnSpacing: 18,
          headingRowColor: WidgetStatePropertyAll(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Driver')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Balance')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Action')),
          ],
          rows: rows.map((r) {
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

            return DataRow(
              cells: [
                DataCell(Text(id)),
                DataCell(
                  SizedBox(
                    width: 130,
                    child: Text(
                      user,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    credit ? 'Credit' : 'Debit',
                    style: TextStyle(
                      color: credit ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${credit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: credit ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(Text('₹${balance.toStringAsFixed(2)}')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
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
                DataCell(
                  SizedBox(
                    width: 112,
                    child: Text(
                      created,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ),
                DataCell(
                  OutlinedButton(
                    onPressed: onViewRow == null ? null : () => onViewRow!(r),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(36, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: const Text('View'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
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
    if (status.contains('success') || status.contains('complete') || status.contains('paid')) {
      return const Color(0xFF2E7D32);
    }
    if (status.contains('pending') || status.contains('process')) {
      return const Color(0xFFEF6C00);
    }
    if (status.contains('fail') || status.contains('reject') || status.contains('error')) {
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