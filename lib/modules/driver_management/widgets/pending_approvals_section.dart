import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/shared/widgets/safe_network_avatar.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '../model/driver_management_row.dart';

class PendingApprovalsSection extends StatelessWidget {
  const PendingApprovalsSection({
    super.key,
    required this.pendingCount,
    required this.rows,
    required this.loadingDriverIds,
    required this.onApprove,
    required this.onReject,
  });

  final int pendingCount;
  final List<DriverManagementRow> rows;
  final Set<int> loadingDriverIds;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        boxShadow: DashboardTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pending Approvals ($pendingCount)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: DashboardTokens.primaryOrange,
                  side: BorderSide(
                    color: DashboardTokens.primaryOrange.withValues(alpha: 0.45),
                  ),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No pending approvals right now.'),
            )
          else
            ...rows.map((r) {
              final busy = loadingDriverIds.contains(r.id);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SafeNetworkAvatar(imageUrl: r.avatarUrl, radius: 14),
                title: Text(r.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('${r.vehicle} · ${r.phone}', style: GoogleFonts.inter(fontSize: 12)),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    ElevatedButton(
                      onPressed: busy ? null : () => onApprove(r.id),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1AAE6F)),
                      child: busy
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Approve'),
                    ),
                    ElevatedButton(
                      onPressed: busy ? null : () => onReject(r.id),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD84B5C)),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
