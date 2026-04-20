import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletActionsRow extends StatefulWidget {
  final VoidCallback onAddMoney;
  final VoidCallback onDeductMoney;
  final VoidCallback onAdjustCommission;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onViewTap;
  final String initialSearch;

  const WalletActionsRow({
    super.key,
    required this.onAddMoney,
    required this.onDeductMoney,
    required this.onAdjustCommission,
    this.onSearchChanged,
    this.onViewTap,
    this.initialSearch = '',
  });

  @override
  State<WalletActionsRow> createState() => _WalletActionsRowState();
}

class _WalletActionsRowState extends State<WalletActionsRow> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
  }

  @override
  void didUpdateWidget(covariant WalletActionsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearch != widget.initialSearch &&
        _searchController.text != widget.initialSearch) {
      _searchController.text = widget.initialSearch;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(
            title: 'Credited Amount ',
            subtitle: 'Credit to Driver',
            icon: Icons.add_rounded,
            color: const Color(0xFF10B981),
            onTap: widget.onAddMoney,
            width: 184,
          ),
          const SizedBox(width: 10),
          _ActionButton(
            title: 'Debited Amount',
            subtitle: 'Debit from Driver',
            icon: Icons.remove_rounded,
            color: const Color(0xFFF43F5E),
            onTap: widget.onDeductMoney,
            width: 190,
          ),
          const SizedBox(width: 10),
          _ActionButton(
            title: 'Adjust Commission',
            subtitle: 'Deduct Driver Commission',
            icon: Icons.percent_rounded,
            color: const Color(0xFFEAB308),
            onTap: widget.onAdjustCommission,
            width: 210,
          ),
          const SizedBox(width: 10),
          _ActionButton(
            title: 'Referal Commission',
            subtitle: 'Deduct Driver Commission',
            icon: Icons.percent_rounded,
            color: Colors.orange,
            onTap: widget.onAdjustCommission,
            width: 210,
          ),
        ],
      ),
    );
  }
}

class _SearchAndView extends StatelessWidget {
  const _SearchAndView({
    required this.compact,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onViewTap,
    this.viewButtonWidth,
  });

  final bool compact;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onViewTap;
  final double? viewButtonWidth;

  @override
  Widget build(BuildContext context) {
    final rowHeight = compact ? 46.0 : 44.0;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: rowHeight,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: TextStyle(fontSize: compact ? 14 : 13.5),
              decoration: InputDecoration(
                hintText: 'Driver Name / Phone / ID',
                hintStyle: TextStyle(
                  fontSize: compact ? 13.2 : 12.8,
                  color: const Color(0xFF6B7280),
                ),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: compact ? 13 : 12,
                      vertical: compact ? 13 : 12,
                    ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide:
                      const BorderSide(color: Color(0xFFD1D5DB), width: 1.1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: viewButtonWidth,
          height: rowHeight,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 18),
              textStyle: TextStyle(
                fontSize: compact ? 15 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: onViewTap,
            child: const Text('View'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double? width;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: width,
          constraints: const BoxConstraints(minWidth: 170),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.6,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.8,
                        color: Color(0xFF6B7280),
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}