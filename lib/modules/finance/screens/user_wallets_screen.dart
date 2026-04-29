import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/network/api_config.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/shared/widgets/safe_network_avatar.dart';

class UserWalletsScreen extends ConsumerStatefulWidget {
  const UserWalletsScreen({super.key});

  static String routeName = 'UserWalletsScreen';
  static String routePath = '/user-wallets';

  @override
  ConsumerState<UserWalletsScreen> createState() => _UserWalletsScreenState();
}

class _UserWalletsScreenState extends ConsumerState<UserWalletsScreen> {
  late Future<List<Map<String, dynamic>>> _walletsFuture;
  final _searchController = TextEditingController();
  String _search = '';

  String _extractApiError(ApiCallResponse response) {
    final body = response.jsonBody;
    if (body is Map) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    final raw = response.bodyText.trim();
    if (raw.isNotEmpty && raw != 'null') {
      return raw;
    }

    return 'Unknown server error';
  }

  List<Map<String, dynamic>> _extractUsers(dynamic jsonBody) {
    final primary = AllUsersCall.usersdata(jsonBody);
    if (primary is List) {
      return primary.whereType<Map<String, dynamic>>().toList();
    }

    final dataNode = AllUsersCall.data(jsonBody);
    if (dataNode is List) {
      return dataNode.whereType<Map<String, dynamic>>().toList();
    }

    return const [];
  }

  List<Map<String, dynamic>> _extractWallets(dynamic jsonBody) {
    return GetWalletsCall.walletsList(jsonBody)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() {
      setState(() => _search = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchUsers() {
    setState(() {
      _walletsFuture = _loadUserWallets();
    });
  }

  Future<List<Map<String, dynamic>>> _loadUserWallets() async {
    final responses = await Future.wait([
      GetWalletsCall.call(token: currentAuthenticationToken),
      AllUsersCall.call(
        token: currentAuthenticationToken,
        page: 1,
        limit: 500,
      ),
    ]);

    final walletsResponse = responses[0];
    final usersResponse = responses[1];

    if (!walletsResponse.succeeded) {
      throw Exception(
        'Failed to load wallets (${walletsResponse.statusCode}): ${_extractApiError(walletsResponse)}',
      );
    }

    if (!usersResponse.succeeded) {
      throw Exception(
        'Failed to load users (${usersResponse.statusCode}): ${_extractApiError(usersResponse)}',
      );
    }

    final wallets = _extractWallets(walletsResponse.jsonBody);
    final users = _extractUsers(usersResponse.jsonBody);
    final usersById = <int, Map<String, dynamic>>{
      for (final user in users)
        if (_asInt(user['user_id']) != null) _asInt(user['user_id'])!: user,
    };

    final merged = wallets
        .where((wallet) => _asInt(wallet['user_id']) != null)
        .map((wallet) {
          final userId = _asInt(wallet['user_id'])!;
          final user = usersById[userId] ?? const <String, dynamic>{};
          return <String, dynamic>{
            ...wallet,
            ...user,
            'resolved_user_id': userId,
            'resolved_name': (user['name']?.toString().trim().isNotEmpty ?? false)
                ? user['name'].toString().trim()
                : 'User #$userId',
            'resolved_phone': (user['phone'] ?? user['mobile_number'] ?? '')
                .toString(),
            'resolved_email': (user['email'] ?? '').toString(),
            'resolved_avatar': (user['profile_image'] ?? user['avatar'] ?? '')
                .toString(),
          };
        })
        .toList();

    merged.sort(
      (a, b) => _asDouble(b['wallet_balance']).compareTo(
        _asDouble(a['wallet_balance']),
      ),
    );

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _walletsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return Center(
            child: CircularProgressIndicator(color: theme.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: theme.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load user wallets',
                  style: theme.bodyMedium.override(color: theme.secondaryText),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _fetchUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final allWallets = snapshot.data!;

        final wallets = _search.isEmpty
          ? allWallets
          : allWallets.where((wallet) {
            final name =
              (wallet['resolved_name'] ?? '').toString().toLowerCase();
            final phone =
              (wallet['resolved_phone'] ?? '').toString().toLowerCase();
            final email =
              (wallet['resolved_email'] ?? '').toString().toLowerCase();
            return name.contains(_search) ||
              phone.contains(_search) ||
              email.contains(_search);
              }).toList();

        double totalBalance = 0;
        for (final wallet in allWallets) {
          totalBalance += _asDouble(wallet['wallet_balance']);
        }

        return RefreshIndicator(
          onRefresh: () async => _fetchUsers(),
          color: theme.primary,
          child: Column(
            children: [
              // ── Summary banner ────────────────────────────────────────
              Container(
                color: theme.primary.withValues(alpha: 0.07),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: 'Total Users',
                        value: allWallets.length.toString(),
                        icon: Icons.people_rounded,
                        color: theme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        label: 'Total Balance',
                        value: '₹${totalBalance.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search bar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: theme.secondaryBackground,
                  ),
                ),
              ),

              // ── List ──────────────────────────────────────────────────
              Expanded(
                child: wallets.isEmpty
                    ? Center(
                        child: Text(
                          allWallets.isEmpty
                              ? 'No user wallets found'
                              : 'No users match your search',
                          style: theme.bodyMedium
                              .override(color: theme.secondaryText),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      itemCount: wallets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                        final wallet = wallets[index];
                        final name =
                          (wallet['resolved_name'] ?? 'Unknown User')
                            .toString();
                        final phone =
                          (wallet['resolved_phone'] ?? '').toString();
                        final email =
                          (wallet['resolved_email'] ?? '').toString();
                        final img =
                          (wallet['resolved_avatar'] ?? '').toString();
                        final walletBalance =
                          _asDouble(wallet['wallet_balance']);
                          final isNegative = walletBalance < 0;

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.alternate),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: SafeNetworkAvatar(
                                imageUrl: img.isNotEmpty && img != 'null'
                                    ? (img.startsWith('http')
                                        ? img
                                        : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}')
                                    : '',
                                radius: 24,
                              ),
                              title: Text(
                                name,
                                style: theme.titleMedium.override(
                                  font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (phone.isNotEmpty)
                                    Text(
                                      phone,
                                      style: theme.bodySmall.override(
                                          color: theme.secondaryText),
                                    ),
                                  if (email.isNotEmpty)
                                    Text(
                                      email,
                                      style: theme.labelSmall.override(
                                        font: GoogleFonts.inter(),
                                        color: theme.secondaryText,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Balance',
                                    style: theme.labelSmall.override(
                                      font: GoogleFonts.inter(),
                                      color: theme.secondaryText,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '₹${walletBalance.toStringAsFixed(2)}',
                                    style: theme.titleMedium.override(
                                      font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold),
                                      color: isNegative
                                          ? theme.error
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.black54),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
