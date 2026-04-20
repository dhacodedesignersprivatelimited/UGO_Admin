import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import '../model/ride_model.dart';

enum _RideListTab { all, ongoing, completed, cancelled }

class RideList extends StatefulWidget {
  const RideList({
    super.key,
    required this.rides,
    /// Increment from parent to open the Cancelled tab (e.g. "View all" on recent cancelled).
    this.cancelTabRequestVersion = 0,
  });

  final List<RideModel> rides;
  final int cancelTabRequestVersion;

  @override
  State<RideList> createState() => _RideListState();
}

class _RideListState extends State<RideList> {
  static const int _perPage = 10;
  int _page = 1;
  _RideListTab _tab = _RideListTab.all;

  static const Color _tabUnderline = Color(0xFFFFB300);

  static const double _colRideId = 118;
  static const double _colUser = 170;
  static const double _colDriver = 170;
  static const double _colRoute = 240;
  static const double _colFare = 80;
  static const double _colStatus = 100;
  static const double _colPayment = 80;
  static const double _colTime = 100;
  static const double _colAction = 60;
  static const double _tableMinWidth = _colRideId +
      _colUser +
      _colDriver +
      _colRoute +
      _colFare +
      _colStatus +
      _colPayment +
      _colTime +
      _colAction;

  @override
  void didUpdateWidget(covariant RideList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rides, widget.rides) ||
        oldWidget.rides.length != widget.rides.length) {
      _page = 1;
    }
    if (widget.cancelTabRequestVersion !=
            oldWidget.cancelTabRequestVersion &&
        widget.cancelTabRequestVersion > 0) {
      _tab = _RideListTab.cancelled;
      _page = 1;
    }
  }

  String _fmtCount(int n) {
    try {
      return NumberFormat('#,###', 'en_IN').format(n);
    } catch (_) {
      return '$n';
    }
  }

  int _countForTab(_RideListTab tab) {
    switch (tab) {
      case _RideListTab.all:
        return widget.rides.length;
      case _RideListTab.ongoing:
        return widget.rides.where((r) => r.status == 'Ongoing').length;
      case _RideListTab.completed:
        return widget.rides.where((r) => r.status == 'Completed').length;
      case _RideListTab.cancelled:
        return widget.rides.where((r) => r.status == 'Cancelled').length;
    }
  }

  List<RideModel> _filteredRides() {
    switch (_tab) {
      case _RideListTab.all:
        return widget.rides;
      case _RideListTab.ongoing:
        return widget.rides.where((r) => r.status == 'Ongoing').toList();
      case _RideListTab.completed:
        return widget.rides.where((r) => r.status == 'Completed').toList();
      case _RideListTab.cancelled:
        return widget.rides.where((r) => r.status == 'Cancelled').toList();
    }
  }

  Widget _countBadge(_RideListTab tab) {
    final n = _countForTab(tab);
    late Color bg;
    late Color fg;
    switch (tab) {
      case _RideListTab.all:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F17);
        break;
      case _RideListTab.ongoing:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF616161);
        break;
      case _RideListTab.completed:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case _RideListTab.cancelled:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _fmtCount(n),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _statusTabBar() {
    Widget tabItem(_RideListTab tab, String label) {
      final selected = _tab == tab;
      return InkWell(
        onTap: () => setState(() {
          _tab = tab;
          _page = 1;
        }),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _countBadge(tab),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: selected ? _tabUnderline : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            tabItem(_RideListTab.all, 'All Rides'),
            tabItem(_RideListTab.ongoing, 'Ongoing'),
            tabItem(_RideListTab.completed, 'Completed'),
            tabItem(_RideListTab.cancelled, 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      case "Ongoing":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _paymentChip(String type) {
    Color color = Colors.blue;

    if (type == "Cash") color = Colors.green;
    if (type == "Card") color = Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _paymentCell(String type) {
    if (type == '—' || type == '-') {
      return Text(
        '—',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      );
    }
    return _paymentChip(type);
  }

  Widget _partyAvatar(String url) {
    final u = url.trim();
    if (u.isEmpty) {
      return const CircleAvatar(
        radius: 14,
        child: Icon(Icons.person, size: 14),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: 28,
        height: 28,
        child: Image.network(
          u,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 14),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade300,
              child: const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            );
          },
        ),
      ),
    );
  }

  List<int?> _visiblePageSlots(int current, int total) {
    if (total <= 1) return const [1];
    if (total <= 9) {
      return List<int>.generate(total, (i) => i + 1);
    }
    final pages = <int>{
      1,
      total,
      current,
      current - 1,
      current + 1,
    };
    if (current <= 4) {
      for (var i = 2; i <= math.min(5, total - 1); i++) {
        pages.add(i);
      }
    } else if (current >= total - 3) {
      for (var i = math.max(2, total - 4); i <= total - 1; i++) {
        pages.add(i);
      }
    } else {
      pages.add(current - 2);
      pages.add(current + 2);
    }
    final sorted = pages.where((p) => p >= 1 && p <= total).toList()..sort();
    final out = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
        out.add(null);
      }
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRides();
    final total = filtered.length;
    final totalPages = total == 0 ? 1 : (total + _perPage - 1) ~/ _perPage;
    final page = _page.clamp(1, totalPages);
    final start = total == 0 ? 0 : (page - 1) * _perPage;
    final end = math.min(start + _perPage, total);
    final pageRides =
        total == 0 ? <RideModel>[] : filtered.sublist(start, end);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusTabBar(),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: _tableMinWidth),
              child: Column(
                children: [
                  _tableHeader(),
                  const Divider(height: 1),
                  ...pageRides.map((r) => _tableRow(context, r)),
                ],
              ),
            ),
          ),
          _pagination(
            currentPage: page,
            totalPages: totalPages,
            totalRides: total,
            startDisplay: total == 0 ? 0 : start + 1,
            endDisplay: end,
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: _colRideId, child: Text("Ride ID", style: _headerStyle)),
          SizedBox(width: _colUser, child: Text("User", style: _headerStyle)),
          SizedBox(width: _colDriver, child: Text("Driver", style: _headerStyle)),
          SizedBox(width: _colRoute, child: Text("Pickup → Drop", style: _headerStyle)),
          SizedBox(width: _colFare, child: Text("Fare", style: _headerStyle)),
          SizedBox(width: _colStatus, child: Text("Status", style: _headerStyle)),
          SizedBox(width: _colPayment, child: Text("Payment", style: _headerStyle)),
          SizedBox(width: _colTime, child: Text("Time", style: _headerStyle)),
          SizedBox(width: _colAction, child: Text("Action", style: _headerStyle)),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, RideModel ride) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _colRideId,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.displayId,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ride.dateSubtitle.isNotEmpty)
                  Text(
                    ride.dateSubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          SizedBox(
            width: _colUser,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _partyAvatar(ride.riderAvatarUrl),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (ride.userPhone.isNotEmpty)
                        Text(
                          ride.userPhone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: _colDriver,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _partyAvatar(ride.driverAvatarUrl),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (ride.driverPhone.isNotEmpty)
                        Text(
                          ride.driverPhone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: _colRoute,
            child: Text(
              "${ride.pickup} → ${ride.drop}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(
            width: _colFare,
            child: Text(
              ride.fare,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(
            width: _colStatus,
            child: _statusChip(ride.status),
          ),

          SizedBox(
            width: _colPayment,
            child: _paymentCell(ride.paymentMethod),
          ),

          SizedBox(
            width: _colTime,
            child: Text(
              ride.distanceDuration,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(
            width: _colAction,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
              color: Colors.blue,
              onPressed: () {
                final rideInt = int.tryParse(ride.id);
                if (rideInt == null) return;
                context.pushNamedAuth(
                  RideDetailsWidget.routeName,
                  context.mounted,
                  queryParameters: {'rideId': rideInt.toString()},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pagination({
    required int currentPage,
    required int totalPages,
    required int totalRides,
    required int startDisplay,
    required int endDisplay,
  }) {
    final summaryText = totalRides == 0
        ? 'No rides'
        : 'Showing $startDisplay to $endDisplay of $totalRides rides';

    final slots = _visiblePageSlots(currentPage, totalPages);
    final controls = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: currentPage <= 1
              ? null
              : () => setState(() => _page = currentPage - 1),
          child: const Text('Previous'),
        ),
      ),
      ...slots.map((slot) {
        if (slot == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Text('…'),
          );
        }
        final selected = slot == currentPage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: InkWell(
            onTap: selected ? null : () => setState(() => _page = slot),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$slot',
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: currentPage >= totalPages
              ? null
              : () => setState(() => _page = currentPage + 1),
          child: const Text('Next'),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 520;
          final summary = Text(
            summaryText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                Wrap(
                  spacing: 0,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: controls,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: summary),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: controls,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: Colors.grey,
);
