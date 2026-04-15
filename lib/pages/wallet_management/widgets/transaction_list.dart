import 'package:flutter/material.dart';

import 'transaction_item.dart';

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
            ...transactions.map(
              (tx) => TransactionCard(
                row: tx,
                onView: onViewRow == null ? null : () => onViewRow!(tx),
              ),
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