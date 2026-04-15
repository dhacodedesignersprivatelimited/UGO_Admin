import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard_tokens.dart';

class QuickActionData {
  const QuickActionData({
    required this.label,
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
}

/// 3×2 grid of pastel quick actions with scale + ripple.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});

  final List<QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    assert(
      actions.length == 6,
      'QuickActions expects exactly 6 actions',
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        return _QuickActionTile(data: actions[index]);
      },
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({required this.data});

  final QuickActionData data;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.96,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _c.animateTo(_c.lowerBound, curve: Curves.easeOut);
  }

  void _onTap() {
    _c.forward();
    widget.data.onTap();
  }

  void _onTapCancel() {
    _c.forward();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final radius = BorderRadius.circular(DashboardTokens.cardRadius);

    return ScaleTransition(
      scale: _c,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: _onTapDown,
          onTap: _onTap,
          onTapCancel: _onTapCancel,
          borderRadius: radius,
          splashColor: d.iconColor.withValues(alpha: 0.12),
          highlightColor: d.iconColor.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              color: d.background,
              borderRadius: radius,
              boxShadow: DashboardTokens.softShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(d.icon, color: d.iconColor, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    d.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.2,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
