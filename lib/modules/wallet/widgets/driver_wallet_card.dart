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
    final initials = driverName
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.trim()[0].toUpperCase())
        .join();

    final resolvedAvatarUrl = _resolveAvatarUrl(avatarUrl);

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
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    resolvedAvatarUrl != null ? NetworkImage(resolvedAvatarUrl) : null,
                child: resolvedAvatarUrl == null
                    ? Text(
                        initials.isEmpty ? 'D' : initials,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      )
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.radio_button_checked, size: 11, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          'ID: DRV1258',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.radio_button_checked, size: 11, color: Colors.deepPurple.shade300),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.circle, size: 9, color: Color(0xFF43A047)),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _metric(
                        label: 'Wallet Balance',
                        value: '₹$balance',
                        valueColor: const Color(0xFF1B8E3E),
                      ),
                    ),
                    Expanded(
                      child: _metric(
                        label: 'Total Rides',
                        value: totalRides.toString(),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹$totalEarnings',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onAddMoney,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14A44D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Credits',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onDeductMoney,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD93045),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Deduct',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (activities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No activity',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                ...activities.take(4).map((e) => _activityRow(e)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: value));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow(Map<String, dynamic> e) {
    final isCredit = (e['type']?.toString().toLowerCase() ?? '') == 'credit';
    final color = isCredit ? const Color(0xFF1B8E3E) : const Color(0xFFD93045);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isCredit ? '+' : '-'} ₹${e['amount']}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e['title']?.toString() ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            e['time']?.toString() ?? '',
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String? _resolveAvatarUrl(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    // Already absolute URL.
    final parsed = Uri.tryParse(value);
    if (parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https') &&
        parsed.host.isNotEmpty) {
      return value;
    }

    // Reject file:// or unsupported schemes to avoid runtime image codec errors.
    if (parsed != null && parsed.scheme.isNotEmpty && parsed.scheme != 'http' && parsed.scheme != 'https') {
      return null;
    }

    // Backend can return relative uploads path; normalize to API host.
    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return 'https://ugo-api.icacorp.org$normalizedPath';
  }
}
