import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final VoidCallback? onView;

  const TransactionCard({
    super.key,
    required this.row,
    this.onView,
  });

  bool get isCredit =>
      (row['flow']?.toString().toLowerCase() ?? '') == 'credit';

  @override
  Widget build(BuildContext context) {
    final color = isCredit ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 22),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row['party_name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(row['description'] ?? ""),
                Text(
                  row['created_at'] ?? "",
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isCredit ? '+' : '-'}₹${row['amount']}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: row['balance_after'].toString()));
                },
                child: Text("₹${row['balance_after']}"),
              ),
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onView?.call();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}