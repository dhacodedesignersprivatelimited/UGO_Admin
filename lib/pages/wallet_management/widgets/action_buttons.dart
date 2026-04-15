import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletActionsRow extends StatelessWidget {
  final VoidCallback onAddMoney;
  final VoidCallback onDeductMoney;
  final VoidCallback onAdjustCommission;

  const WalletActionsRow({
    super.key,
    required this.onAddMoney,
    required this.onDeductMoney,
    required this.onAdjustCommission,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            title: "Add Money",
            icon: Icons.add,
            color: Colors.green,
            onTap: onAddMoney,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            title: "Deduct",
            icon: Icons.remove,
            color: Colors.red,
            onTap: onDeductMoney,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            title: "Commission",
            icon: Icons.percent,
            color: Colors.orange,
            onTap: onAdjustCommission,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // 🔥 vibration feedback
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}