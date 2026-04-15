import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One row in [RecentRidesTable] (horizontal scroll table).
class RideItem extends StatelessWidget {
  const RideItem({
    super.key,
    required this.theme,
    required this.rideIdLabel,
    required this.riderName,
    required this.riderPhone,
    required this.riderImg,
    required this.driverName,
    required this.driverPhone,
    required this.driverImg,
    required this.pickup,
    required this.drop,
    required this.fare,
    required this.humanStatus,
    required this.statusColor,
    required this.time,
    this.onTap,
  });

  final FlutterFlowTheme theme;
  final String rideIdLabel;
  final String riderName;
  final String riderPhone;
  final String riderImg;
  final String driverName;
  final String driverPhone;
  final String driverImg;
  final String pickup;
  final String drop;
  final String fare;
  final String humanStatus;
  final Color statusColor;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
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
                  name: riderName,
                  phone: riderPhone,
                  imageUrl: riderImg,
                ),
              ),
              Expanded(
                flex: 5,
                child: _personBlock(
                  name: driverName,
                  phone: driverPhone,
                  imageUrl: driverImg,
                ),
              ),
              Expanded(
                flex: 6,
                child: _routeBlock(pickup: pickup, drop: drop),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        ),
      ),
    );
  }

  Widget _personBlock({
    required String name,
    required String phone,
    required String imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SafeNetworkAvatar(imageUrl: imageUrl, radius: 18),
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

  Widget _routeBlock({required String pickup, required String drop}) {
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
}
