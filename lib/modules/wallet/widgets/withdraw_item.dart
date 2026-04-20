import 'package:flutter/material.dart';

class WithdrawItem extends StatelessWidget {
  final String? requestId;
  final String driverName;
  final String phone;
  final String amount;
  final String? transferMode;
  final String status;
  final String date;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const WithdrawItem({
    super.key,
    this.requestId,
    required this.driverName,
    required this.phone,
    required this.amount,
    this.transferMode,
    required this.status,
    required this.date,
    required this.onApprove,
    required this.onReject,
  });

  Color _statusColor() {
    final s = status.toLowerCase();
    if (s.contains('paid') || s.contains('complete') || s.contains('success')) {
      return Colors.green;
    }
    if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
      return Colors.red;
    }
    if (s.contains('pending') || s == 'processing') {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String get _statusLabel {
    final s = status.toLowerCase();
    if (s == 'pending_manual_transfer') return 'Pending transfer';
    if (s == 'processing') return 'Processing';
    if (s.contains('paid') || s.contains('complete')) return 'Paid';
    if (s.contains('fail')) return 'Failed';
    return status.replaceAll('_', ' ');
  }

  bool get _canApproveOrReject {
    final s = status.toLowerCase();
    if (s.contains('paid') ||
        s.contains('complete') ||
        s.contains('fail') ||
        s.contains('reject')) {
      return false;
    }
    return s.contains('pending') || s == 'processing';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          /// TOP ROW (Driver + Amount)
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 10),

              /// NAME + PHONE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (requestId != null && requestId!.trim().isNotEmpty)
                      Text(
                        requestId!.trim(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    if (requestId != null && requestId!.trim().isNotEmpty)
                      const SizedBox(height: 2),
                    Text(
                      driverName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              /// AMOUNT (pass digits only, or a string that already includes ₹)
              Text(
                amount.startsWith('₹') ? amount : '₹$amount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          if (transferMode != null && transferMode!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    transferMode!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          /// STATUS + DATE
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// ACTION BUTTONS (pending / processing payout rows)
          if (_canApproveOrReject)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}