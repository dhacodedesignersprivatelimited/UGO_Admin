import 'package:flutter/material.dart';

class WithdrawRequestList extends StatelessWidget {
  final List<Map<String, dynamic>> withdraws;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(Map<String, dynamic>)? onApprove;
  final Function(Map<String, dynamic>)? onReject;

  const WithdrawRequestList({
    super.key,
    required this.withdraws,
    this.isLoading = false,
    this.onRefresh,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔄 LOADING STATE
    if (isLoading) {
      return const _LoadingWithdrawList();
    }

    /// ❌ EMPTY STATE
    if (withdraws.isEmpty) {
      return const _EmptyWithdrawState();
    }

    /// ✅ LIST
    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) onRefresh!();
      },
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: _WithdrawDataTable(
          rows: withdraws,
          onApprove: onApprove,
          onReject: onReject,
        ),
      ),
    );
  }
}

class _WithdrawDataTable extends StatelessWidget {
  const _WithdrawDataTable({
    required this.rows,
    required this.onApprove,
    required this.onReject,
  });

  final List<Map<String, dynamic>> rows;
  final Function(Map<String, dynamic>)? onApprove;
  final Function(Map<String, dynamic>)? onReject;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 42,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                horizontalMargin: 10,
                columnSpacing: 18,
                headingRowColor: WidgetStatePropertyAll(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('Request ID')),
                  DataColumn(label: Text('Driver')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Mode')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Action')),
                ],
                rows: rows.map((w) {
                  final status = (w['status']?.toString() ?? 'pending').trim();
                  final statusColor = _statusColor(status);
                  final canAct = _canApproveOrReject(status);
                  final amount = w['amount']?.toString() ?? '0';
                  final mode = (w['upi_or_bank']?.toString() ?? '').trim();

                  return DataRow(
                    cells: [
                      DataCell(Text(w['wr_id']?.toString() ?? w['id']?.toString() ?? '-')),
                      DataCell(
                        SizedBox(
                          width: 130,
                          child: Text(
                            w['driver_name']?.toString() ?? 'Unknown',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(w['phone']?.toString() ?? '-')),
                      DataCell(
                        Text(
                          amount.startsWith('₹') ? amount : '₹$amount',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            mode.isEmpty ? '-' : mode,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _statusLabel(status),
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
                          width: 120,
                          child: Text(
                            w['date']?.toString() ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      DataCell(
                        !canAct
                            ? const Text('-', style: TextStyle(color: Colors.grey))
                            : Row(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: onApprove == null ? null : () => onApprove!(w),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E7D32),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Approve', style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    height: 30,
                                    child: OutlinedButton(
                                      onPressed: onReject == null ? null : () => onReject!(w),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFC62828),
                                        side: const BorderSide(color: Color(0xFFC62828)),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Reject', style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _statusLabel(String status) {
    final s = status.toLowerCase();
    if (s == 'pending_manual_transfer') return 'Pending transfer';
    if (s == 'processing') return 'Processing';
    if (s.contains('paid') || s.contains('complete') || s.contains('success')) {
      return 'Paid';
    }
    if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
      return 'Failed';
    }
    return status.replaceAll('_', ' ');
  }

  static Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('paid') || s.contains('complete') || s.contains('success')) {
      return const Color(0xFF2E7D32);
    }
    if (s.contains('pending') || s == 'processing') {
      return const Color(0xFFEF6C00);
    }
    if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
      return const Color(0xFFC62828);
    }
    return const Color(0xFF455A64);
  }

  static bool _canApproveOrReject(String status) {
    final s = status.toLowerCase();
    if (s.contains('paid') ||
        s.contains('complete') ||
        s.contains('fail') ||
        s.contains('reject')) {
      return false;
    }
    return s.contains('pending') || s == 'processing';
  }
}

/// 🔄 LOADING SKELETON
class _LoadingWithdrawList extends StatelessWidget {
  const _LoadingWithdrawList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
            (index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// ❌ EMPTY STATE
class _EmptyWithdrawState extends StatelessWidget {
  const _EmptyWithdrawState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Icon(Icons.account_balance_wallet_outlined,
              size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Withdraw Requests",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}