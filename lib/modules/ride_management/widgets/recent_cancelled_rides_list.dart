import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '../view/ride_row_data.dart';

/// Card listing recent cancelled rides (id, route, time, cancel badge).
class RecentCancelledRidesList extends StatelessWidget {
  const RecentCancelledRidesList({
    super.key,
    required this.rows,
    this.onViewAll,
    this.maxRows = 3,
  });

  final List<RideRowData> rows;
  final VoidCallback? onViewAll;
  final int maxRows;

  static const Color _badgeBg = Color(0xFFFFE4E6);
  static const Color _badgeFg = Color(0xFFB91C1C);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final visible = rows.take(maxRows).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        boxShadow: DashboardTokens.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Recent Cancelled Rides',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: onViewAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.secondaryText,
                    side: BorderSide(
                      color: theme.alternate.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Center(
                child: Text(
                  'No cancelled rides in this list',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.secondaryText,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              itemCount: visible.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: theme.alternate.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final r = visible[index];
                final route = '${r.pickup} -> ${r.drop}'.replaceAll('— -> —', '—');
                final subtitle = r.rideSubtitle;
                final id = r.rideId;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: id == null
                        ? null
                        : () => context.pushNamedAuth(
                              RideDetailsWidget.routeName,
                              context.mounted,
                              queryParameters: {'rideId': id.toString()},
                            ),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 92,
                            child: Text(
                              r.rideIdLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  route,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: theme.secondaryText,
                                  ),
                                ),
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: theme.secondaryText.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: _badgeBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                r.cancelSourceLabel,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _badgeFg,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
