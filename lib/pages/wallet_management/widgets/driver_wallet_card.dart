import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverWalletCard extends StatelessWidget {
  final String driverName;
  final String phone;
  final String balance;
  final int totalRides;
  final String totalEarnings;
  final String? avatarUrl;

  final VoidCallback? onAddMoney;
  final VoidCallback? onDeductMoney;

  final List<Map<String, dynamic>> activities;

  const DriverWalletCard({
    super.key,
    required this.driverName,
    required this.phone,
    required this.balance,
    required this.totalRides,
    required this.totalEarnings,
    required this.activities,
    this.avatarUrl,
    this.onAddMoney,
    this.onDeductMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
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

              /// ONLINE DOT
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          /// 💰 BALANCE + RIDES
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                /// BALANCE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Wallet Balance",
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(
                              ClipboardData(text: balance));
                        },
                        child: Text(
                          "₹$balance",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// RIDES
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Total Rides",
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        totalRides.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 💸 TOTAL EARNINGS
          Text(
            "₹$totalEarnings",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          /// ⚡ ACTIONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAddMoney,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Add Money"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDeductMoney,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Deduct Money"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 📊 RECENT ACTIVITY
          const Text(
            "Recent Activity",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Column(
            children: activities.map((e) {
              final isCredit = e['type'] == "credit";

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: isCredit
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    isCredit ? Icons.add : Icons.remove,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  "${isCredit ? "+" : "-"}₹${e['amount']}",
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(e['title']),
                trailing: Text(
                  e['time'],
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}