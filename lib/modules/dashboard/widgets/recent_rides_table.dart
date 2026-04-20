import 'dart:math' as math;

import '/modules/ride_management/view/ride_management_screen.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import '/modules/ride_management/view/ride_row_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view/dashboard_tokens.dart';
import 'ride_item.dart';

/// Horizontally scrollable recent rides card.
class RecentRidesTable extends StatelessWidget {
  const RecentRidesTable({
    super.key,
    required this.rides,
    this.userById = const {},
    this.driverById = const {},
    this.isLoading = false,
  });

  final List<dynamic> rides;
  final Map<int, Map<String, dynamic>> userById;
  final Map<int, Map<String, dynamic>> driverById;
  final bool isLoading;

  void _openRideDetails(BuildContext context, int rideId) {
    context.pushNamedAuth(
      RideDetailsWidget.routeName,
      context.mounted,
      queryParameters: {'rideId': rideId.toString()},
    );
  }

  void _openAllRides(BuildContext context) {
    context.pushNamedAuth(
      RideManagementScreen.routeName,
      context.mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final screenW = MediaQuery.sizeOf(context).width;
    const horizontalPad = 32.0;
    final viewport = math.max(screenW - horizontalPad, 280.0);
    const tableMinW = 720.0;
    final contentW = viewport < tableMinW ? tableMinW : viewport;

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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Recent Rides',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: DashboardTokens.primaryOrange,
                ),
              ),
            )
          else if (rides.isEmpty)
            _emptyState(context, theme)
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: contentW,
                child: Column(
                  children: [
                    _tableHeader(theme: theme),
                    ...List.generate(rides.length, (index) {
                      final raw = rides[index];
                      final base = RideRowData.tryParse(raw);
                      if (base == null) return const SizedBox.shrink();
                      final uid = base.riderUserId;
                      final did = base.linkedDriverId;
                      final row = RideRowData.tryParse(
                        raw,
                        userDetail: uid != null ? userById[uid] : null,
                        driverDetail: did != null ? driverById[did] : null,
                      )!;
                      final statusColor = row.statusColor(theme);

                      return RideItem(
                        theme: theme,
                        rideIdLabel: row.rideIdLabel,
                        riderName: row.riderName,
                        riderPhone: row.riderPhone,
                        riderImg: row.riderImageUrl,
                        driverName: row.driverName,
                        driverPhone: row.driverPhone,
                        driverImg: row.driverImageUrl,
                        pickup: row.pickup,
                        drop: row.drop,
                        fare: row.fare,
                        humanStatus: row.humanStatus,
                        statusColor: statusColor,
                        time: row.time24,
                        onTap: row.rideId != null
                            ? () => _openRideDetails(context, row.rideId!)
                            : null,
                      )
                          .animate()
                          .fadeIn(
                            duration: 350.ms,
                            delay: (40 * index).ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(begin: 0.04, end: 0);
                    }),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _openAllRides(context),
                style: TextButton.styleFrom(
                  foregroundColor: DashboardTokens.primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Rides',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: DashboardTokens.primaryOrange),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader({required FlutterFlowTheme theme}) {
    TextStyle hStyle() => GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.secondaryText,
          letterSpacing: 0.2,
        );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 88, child: Text('Ride ID', style: hStyle())),
          Expanded(flex: 5, child: Text('User', style: hStyle())),
          Expanded(flex: 5, child: Text('Driver', style: hStyle())),
          Expanded(flex: 6, child: Text('Pickup → Drop', style: hStyle())),
          SizedBox(width: 72, child: Text('Fare', style: hStyle())),
          SizedBox(width: 96, child: Text('Status', style: hStyle())),
          SizedBox(
            width: 48,
            child: Text('Time', textAlign: TextAlign.end, style: hStyle()),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        children: [
          Icon(Icons.local_taxi_rounded, size: 44, color: theme.secondaryText),
          const SizedBox(height: 12),
          Text(
            'No recent rides',
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or open the full list.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _openAllRides(context),
            icon: const Icon(Icons.list_alt_rounded,
                color: DashboardTokens.primaryOrange, size: 20),
            label: Text(
              'View All Rides',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: DashboardTokens.primaryOrange,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: DashboardTokens.primaryOrange.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
