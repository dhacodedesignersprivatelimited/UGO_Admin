import 'dart:math' as math;

import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/ride_management/ride_row_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideTable extends StatelessWidget {
  const RideTable({
    super.key,
    required this.rides,
    this.userById = const {},
    this.driverById = const {},
    this.isLoading = false,
  });

  final List<dynamic> rides;
  /// From [GetUserByIdCall] keyed by rider id.
  final Map<int, Map<String, dynamic>> userById;
  /// From [GetDriverByIdCall] keyed by driver id.
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
      RideManagementWidget.routeName,
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
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
              child: Center(child: CircularProgressIndicator()),
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
                    _tableHeader(theme),
                    ...List.generate(rides.length, (index) {
                      final raw = rides[index];
                      final base = RideRowData.tryParse(raw);
                      if (base == null) return const SizedBox.shrink();
                      final uid = base.riderUserId;
                      final did = base.linkedDriverId;
                      final row = RideRowData.tryParse(
                        raw,
                        userDetail:
                            uid != null ? userById[uid] : null,
                        driverDetail:
                            did != null ? driverById[did] : null,
                      )!;
                      final statusColor = row.statusColor(theme);

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 320 + index * 50),
                        tween: Tween(begin: 0, end: 1),
                        builder: (context, t, child) {
                          return Opacity(
                            opacity: t,
                            child: child,
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: row.rideId != null
                                ? () => _openRideDetails(
                                      context,
                                      row.rideId!,
                                    )
                                : null,
                            child: _tableRow(
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
                            ),
                          ),
                        ),
                      );
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
                  foregroundColor: theme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    Icon(Icons.arrow_forward_rounded,
                        size: 18, color: theme.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(FlutterFlowTheme theme) {
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
          SizedBox(width: 48, child: Text('Time', textAlign: TextAlign.end, style: hStyle())),
        ],
      ),
    );
  }

  Widget _tableRow({
    required FlutterFlowTheme theme,
    required String rideIdLabel,
    required String riderName,
    required String riderPhone,
    required String riderImg,
    required String driverName,
    required String driverPhone,
    required String driverImg,
    required String pickup,
    required String drop,
    required String fare,
    required String humanStatus,
    required Color statusColor,
    required String time,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.35)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              rideIdLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _personBlock(
              theme: theme,
              name: riderName,
              phone: riderPhone,
              imageUrl: riderImg,
            ),
          ),
          Expanded(
            flex: 5,
            child: _personBlock(
              theme: theme,
              name: driverName,
              phone: driverPhone,
              imageUrl: driverImg,
            ),
          ),
          Expanded(
            flex: 6,
            child: _routeBlock(theme: theme, pickup: pickup, drop: drop),
          ),
          SizedBox(
            width: 72,
            child: Text(
              fare,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  humanStatus,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              time,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personBlock({
    required FlutterFlowTheme theme,
    required String name,
    required String phone,
    required String imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SafeNetworkAvatar(
          imageUrl: imageUrl,
          radius: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (phone.isNotEmpty)
                Text(
                  phone,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeBlock({
    required FlutterFlowTheme theme,
    required String pickup,
    required String drop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                pickup,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
        Text(
          drop,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: theme.secondaryText,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
            icon: Icon(Icons.list_alt_rounded, color: theme.primary, size: 20),
            label: Text(
              'View All Rides',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: theme.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.primary.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
