import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Flags, risk profiles, and admin actions (block user, finance flag, resolve).
class FinanceRiskTab extends StatefulWidget {
  const FinanceRiskTab({super.key});

  @override
  State<FinanceRiskTab> createState() => _FinanceRiskTabState();
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class _FinanceRiskTabState extends State<FinanceRiskTab> {
  bool _loading = true;
  String? _error;
  List<dynamic> _flags = const [];
  List<dynamic> _profiles = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not signed in';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fr = await Future.wait([
        GetAdminFinanceFlagsCall.call(token: token, limit: 80),
        GetAdminFinanceRiskProfilesCall.call(token: token, limit: 40, minScore: 30),
      ]);
      if (!fr[0].succeeded) {
        setState(() {
          _loading = false;
          _error = getJsonField(fr[0].jsonBody, r'''$.message''')?.toString() ?? 'Flags failed';
        });
        return;
      }
      setState(() {
        _loading = false;
        _flags = GetAdminFinanceFlagsCall.flagsList(fr[0].jsonBody);
        _profiles = fr[1].succeeded ? GetAdminFinanceRiskProfilesCall.profilesList(fr[1].jsonBody) : const [];
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _blockUser(int userId) async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block user?'),
        content: Text('User id $userId will be blocked via /admins/block-user.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Block')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final r = await BlockUserCall.call(token: token, userId: userId, reasonForBlocking: 'Finance risk panel');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.succeeded ? 'User blocked' : (getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed'))),
    );
  }

  Future<void> _walletReviewFlag({int? userId, int? driverId}) async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final r = await PostAdminFinanceFlagCall.call(
      token: token,
      userId: userId,
      driverId: driverId,
      flagType: 'wallet_review',
      severity: 'high',
      reason: 'Wallet frozen for review (finance control center)',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.succeeded ? 'Review flag created' : (getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed'))),
    );
    if (r.succeeded) _load();
  }

  Future<void> _showDriverIntel(int driverId) async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final r = await GetAdminFinanceDriverIntelCall.call(token: token, driverId: driverId);
    if (!mounted) return;
    final snap = GetAdminFinanceDriverIntelCall.snapshotMap(r.jsonBody);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Driver $driverId · intel'),
        content: SingleChildScrollView(
          child: SelectableText(
            snap != null ? snap.toString() : (r.succeeded ? '{}' : (getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed')),
            style: GoogleFonts.jetBrainsMono(fontSize: 11),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _resolveFlag(int flagId) async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final r = await PostAdminFinanceResolveFlagCall.call(token: token, flagId: flagId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.succeeded ? 'Flag resolved' : (getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed'))),
    );
    if (r.succeeded) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(_error!, textAlign: TextAlign.center)),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: Text('Fraud & risk', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
            ],
          ),
          Text('GET /api/admins/finance/flags · /finance/risk-profiles', style: theme.bodySmall),
          const SizedBox(height: 16),
          Text('Open flags', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_flags.isEmpty)
            Text('No open finance_account_flags.', style: theme.bodySmall)
          else
            ..._flags.map((f) {
              final m = f as Map<String, dynamic>;
              final id = (m['id'] as num?)?.toInt();
              final uid = _toInt(m['user_id']);
              final did = _toInt(m['driver_id']);
              return Card(
                child: ListTile(
                  title: Text('${m['flag_type']} · ${m['severity']}'),
                  subtitle: Text('id $id · user $uid · driver $did\n${m['reason'] ?? ''}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (id == null) return;
                      if (v == 'resolve') await _resolveFlag(id);
                      if (v == 'block' && uid != null) await _blockUser(uid);
                      if (v == 'freeze') await _walletReviewFlag(userId: uid, driverId: did);
                      if (!context.mounted) return;
                      if (v == 'user' && uid != null) {
                        context.pushNamed(UserDetailsWidget.routeName, queryParameters: {'userId': '$uid'});
                      }
                      if (v == 'driver' && did != null) {
                        context.pushNamed(DriverDetailsWidget.routeName, queryParameters: {'driverId': '$did'});
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (uid != null) const PopupMenuItem(value: 'user', child: Text('Open user')),
                      if (did != null) const PopupMenuItem(value: 'driver', child: Text('Open driver')),
                      const PopupMenuItem(value: 'freeze', child: Text('Flag wallet review')),
                      if (uid != null) const PopupMenuItem(value: 'block', child: Text('Block user')),
                      const PopupMenuItem(value: 'resolve', child: Text('Resolve flag')),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          Text('Risk profiles (score ≥ 30)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_profiles.isEmpty)
            Text('No profiles in range.', style: theme.bodySmall)
          else
            ..._profiles.map((p) {
              final m = p as Map<String, dynamic>;
              final uid = _toInt(m['user_id']);
              final did = _toInt(m['driver_id']);
              return Card(
                child: ListTile(
                  title: Text('Score ${m['risk_score']}'),
                  subtitle: Text('user $uid · driver $did'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (did != null)
                        IconButton(
                          tooltip: 'Payout anomaly snapshot',
                          icon: const Icon(Icons.insights_rounded),
                          onPressed: () => _showDriverIntel(did),
                        ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded),
                        onPressed: () {
                          if (uid != null) {
                            context.pushNamed(UserDetailsWidget.routeName, queryParameters: {'userId': '$uid'});
                          } else if (did != null) {
                            context.pushNamed(DriverDetailsWidget.routeName, queryParameters: {'driverId': '$did'});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          Text('Suspicious payouts', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text('Review high-value or stale items in Driver payouts.', style: theme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.pushNamed(DriverPayoutsWidget.routeName),
            icon: const Icon(Icons.payments_rounded),
            label: const Text('Open payout queue'),
          ),
        ],
      ),
    );
  }
}
