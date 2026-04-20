import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/dashboard/view/dashboard_tokens.dart';

class DriverFilterStrip extends StatelessWidget {
  const DriverFilterStrip({
    super.key,
    required this.searchController,
    required this.onFilterTap,
    required this.onClearTap,
    required this.hasActiveSearch,
    required this.onResetAllTap,
    required this.showResetAll,
  });

  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final VoidCallback onClearTap;
  final bool hasActiveSearch;
  final VoidCallback onResetAllTap;
  final bool showResetAll;

  @override
  Widget build(BuildContext context) {
    Widget field(String label, {IconData? icon}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            if (icon != null) Icon(icon, size: 16, color: Colors.black45),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        boxShadow: DashboardTokens.cardShadow,
      ),
      child: Column(
      children: [
        Row(
          children: [
            Expanded(child: field('Select Date', icon: Icons.calendar_today_outlined)),
            const SizedBox(width: 8),
            Expanded(child: field('All Status', icon: Icons.keyboard_arrow_down)),
            const SizedBox(width: 8),
            Expanded(child: field('Vehicle Type', icon: Icons.keyboard_arrow_down)),
            if (showResetAll) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onResetAllTap,
                child: const Text('Reset all'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: field('All Cities', icon: Icons.keyboard_arrow_down)),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: searchController,
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 18),
                  hintText: 'Search by name, phone or ID...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (hasActiveSearch) ...[
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: onClearTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onFilterTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardTokens.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.filter_alt_outlined, size: 16),
                label: const Text('Filter'),
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
