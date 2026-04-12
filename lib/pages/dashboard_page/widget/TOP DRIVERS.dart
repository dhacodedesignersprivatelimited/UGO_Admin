import '/backend/api_requests/api_config.dart';
import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashboard card: ranked drivers with avatar, name, ride count, and earnings.
class TopDrivers extends StatelessWidget {
  const TopDrivers({
    super.key,
    required this.drivers,
    this.isLoading = false,
    this.maxRows = 5,
  });

  final List<dynamic> drivers;
  final bool isLoading;
  final int maxRows;

  static String _name(dynamic d, int index) {
    if (d is! Map) return 'Driver ${index + 1}';
    final m = Map<String, dynamic>.from(d);
    final first = m['first_name']?.toString().trim() ?? '';
    final last = m['last_name']?.toString().trim() ?? '';
    final n = '$first $last'.trim();
    if (n.isNotEmpty) return n;
    final fallback = m['name']?.toString().trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return 'Driver ${index + 1}';
  }

  static int? _ridesCount(Map<String, dynamic> d) {
    for (final k in [
      'today_rides',
      'rides_today',
      'completed_today',
      'completed_rides',
      'total_trips',
      'ride_count',
      'total_rides',
    ]) {
      final v = _parseInt(d[k]);
      if (v != null) return v;
    }
    return null;
  }

  static String _earningsLabel(Map<String, dynamic> d) {
    for (final k in [
      'today_earnings',
      'daily_earnings',
      'total_earnings',
      'lifetime_earnings',
      'wallet_balance',
      'balance',
    ]) {
      final v = _parseDouble(d[k]);
      if (v != null) {
        final fmt = NumberFormat('#,##0.00', 'en_IN');
        return '₹${fmt.format(v)}';
      }
    }
    return '—';
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static String? _imageUrl(dynamic d) {
    if (d is! Map) return null;
    final raw = d['profile_image']?.toString();
    if (raw == null || raw.isEmpty || raw == 'null') return null;
    if (raw.startsWith('http')) return raw;
    return '${ApiConfig.baseUrl}/${raw.replaceFirst(RegExp(r'^/'), '')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final visible = drivers.take(maxRows).toList();

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
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Top Drivers Today',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => context.pushNamedAuth(
                    DriversWidget.routeName,
                    context.mounted,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.secondaryText,
                    side: BorderSide(color: theme.alternate.withValues(alpha: 0.9)),
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
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (drivers.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Center(
                child: Text(
                  'No driver data yet',
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
                color: theme.alternate.withValues(alpha: 0.35),
              ),
              itemBuilder: (context, index) {
                final d = visible[index];
                final m = d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
                final rank = index + 1;
                final id = castToType<int>(m['id']);
                final url = _imageUrl(d);
                final rides = _ridesCount(m);
                final earnings = _earningsLabel(m);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: id != null
                        ? () => context.pushNamedAuth(
                              DriverDetailsWidget.routeName,
                              context.mounted,
                              queryParameters: {'driverId': id.toString()},
                            )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '$rank',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.secondaryText,
                              ),
                            ),
                          ),
                          SafeNetworkAvatar(
                            imageUrl: url ?? '',
                            radius: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _name(d, index),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryText,
                                  ),
                                ),
                                if (rides != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '$rides Rides',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            earnings,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText,
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
