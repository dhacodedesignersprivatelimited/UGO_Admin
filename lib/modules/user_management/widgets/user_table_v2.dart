import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/shared/widgets/safe_network_avatar.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '../models/user_management_row.dart';
import '../view_models/user_management_state.dart';

class UserTableV2 extends StatelessWidget {
  const UserTableV2({
    super.key,
    required this.activeTab,
    required this.tabCounts,
    required this.rows,
    required this.startDisplay,
    required this.endDisplay,
    required this.totalRows,
    required this.onViewUser,
    required this.onTabChanged,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSelected,
    required this.canPrevious,
    required this.canNext,
    required this.currentPage,
    required this.totalPages,
    required this.loadingUserIds,
    required this.onBlock,
    required this.pageSize,
    required this.onPageSizeChanged,
    required this.pageSizeOptions,
  });

  final UserManagementTab activeTab;
  final Map<UserManagementTab, int> tabCounts;
  final List<UserManagementRow> rows;
  final int startDisplay;
  final int endDisplay;
  final int totalRows;
  final void Function(int userId) onViewUser;
  final ValueChanged<UserManagementTab> onTabChanged;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final ValueChanged<int> onPageSelected;
  final bool canPrevious;
  final bool canNext;
  final int currentPage;
  final int totalPages;
  final List<int> loadingUserIds;
  final ValueChanged<int> onBlock;
  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;
  final List<int> pageSizeOptions;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    Widget tabChip(UserManagementTab tab, String label, Color color) {
      final selected = tab == activeTab;
      return InkWell(
        onTap: () => onTabChanged(tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFFF2B300) : Colors.transparent,
                width: 2.6,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: selected
                      ? const Color(0xFF111111)
                      : const Color(0xFF616161),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tabCounts[tab] ?? 0}',
                  style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final slots = _visiblePageSlots(currentPage, totalPages);
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: theme.alternate.withValues(alpha: 0.45)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tabChip(UserManagementTab.all, 'All Users', Colors.grey),
                  tabChip(UserManagementTab.active, 'Active', Colors.green),
                  tabChip(UserManagementTab.blocked, 'Blocked', Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            _emptyState(theme)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = math.max(constraints.maxWidth, 820.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        _tableHeader(theme),
                        ...rows.map((r) => _tableRow(r, theme)),
                      ],
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final summary = Text(
                  totalRows == 0
                      ? 'No users'
                      : 'Showing $startDisplay to $endDisplay of $totalRows users',
                  style: GoogleFonts.inter(fontSize: 13),
                );

                final controls = SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: canPrevious ? onPreviousPage : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 6),
                      ...slots.map((slot) {
                        if (slot == null) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('...'),
                          );
                        }
                        final selected = slot == currentPage;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: selected ? null : () => onPageSelected(slot),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    selected ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$slot',
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.black,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 6),
                      OutlinedButton(
                        onPressed: canNext ? onNextPage : null,
                        child: const Text('Next'),
                      ),
                      const SizedBox(width: 10),
                      PopupMenuButton<int>(
                        onSelected: onPageSizeChanged,
                        itemBuilder: (context) => pageSizeOptions
                            .map(
                              (v) => PopupMenuItem<int>(
                                value: v,
                                child: Text(
                                  '$v / page',
                                  style: GoogleFonts.inter(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.alternate.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$pageSize / page',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.primaryText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: theme.secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summary,
                      const SizedBox(height: 8),
                      controls,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: summary),
                    const SizedBox(width: 10),
                    Flexible(child: controls),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(FlutterFlowTheme theme) {
    final style = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: theme.secondaryText,
      letterSpacing: 0.2,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.6)),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const SizedBox(
              width: 40,
              child: Icon(
                Icons.check_box_outline_blank,
                size: 18,
                color: Colors.black38,
              ),
            ),
            Expanded(flex: 12, child: Text('User ID', style: style)),
            Expanded(flex: 26, child: Text('User Name', style: style)),
            Expanded(flex: 22, child: Text('Email', style: style)),
            Expanded(flex: 14, child: Text('Status', style: style)),
            Expanded(flex: 14, child: Text('Wallet Balance', style: style)),
            Expanded(flex: 10, child: Text('Total Rides', style: style)),
            const SizedBox(width: 88, child: Text('Action')),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String status) {
    Color fg = const Color(0xFF198754);
    Color bg = const Color(0xFFE8F6ED);
    if (status == 'Blocked') {
      fg = const Color(0xFFC63B4D);
      bg = const Color(0xFFFDECEF);
    } else if (status == 'Inactive') {
      fg = Colors.black54;
      bg = const Color(0xFFF2F2F2);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _tableRow(UserManagementRow r, FlutterFlowTheme theme) {
    final busy = loadingUserIds.contains(r.id);
    final rideFmt = NumberFormat.decimalPattern('en_IN');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.alternate.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 40,
            child: Icon(
              Icons.check_box_outline_blank,
              size: 18,
              color: Colors.black38,
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              'USR${r.id}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 26,
            child: Row(
              children: [
                SafeNetworkAvatar(imageUrl: r.avatarUrl, radius: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        r.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 11, color: theme.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 22,
            child: Text(r.email, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusPill(r.status),
                if (r.statusSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    r.statusSubtitle,
                    style: TextStyle(fontSize: 11, color: theme.secondaryText),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(r.walletBalance,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 10,
            child: Text(rideFmt.format(r.totalRides)),
          ),
          SizedBox(
            width: 88,
            child: Row(
              children: [
                _actionIconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  fg: const Color(0xFF4A87C2),
                  bg: const Color(0xFFF3F8FE),
                  tooltip: 'View profile',
                  onPressed: () => onViewUser(r.id),
                ),
                _actionIconButton(
                  icon: Icon(
                    r.isBlocked
                        ? Icons.block_rounded
                        : Icons.check_circle_outline,
                    size: 16,
                  ),
                  fg: r.isBlocked
                      ? const Color(0xFFC63B4D)
                      : const Color(0xFF198754),
                  bg: r.isBlocked
                      ? const Color(0xFFFFF2F4)
                      : const Color(0xFFF0FBF5),
                  tooltip: r.isBlocked ? 'Unblock' : 'Block',
                  onPressed: busy ? null : () => onBlock(r.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        children: [
          Icon(Icons.groups_rounded, size: 44, color: theme.secondaryText),
          const SizedBox(height: 12),
          Text(
            'No users found',
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing tabs or filters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIconButton({
    required Widget icon,
    required Color fg,
    required Color bg,
    String? tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: fg.withValues(alpha: 0.18)),
        ),
        child: IconTheme(
          data: IconThemeData(color: fg, size: 16),
          child: Center(
            child: onPressed == null
                ? icon
                : InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onPressed,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(child: icon),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  List<int?> _visiblePageSlots(int current, int total) {
    if (total <= 1) return const [1];
    if (total <= 9) return List<int>.generate(total, (i) => i + 1);
    final pages = <int>{1, total, current, current - 1, current + 1};
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
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add(null);
      out.add(sorted[i]);
    }
    return out;
  }
}
