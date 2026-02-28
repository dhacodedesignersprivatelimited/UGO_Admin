import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/components/responsive_body.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blocked_users_model.dart';
export 'blocked_users_model.dart';

class BlockedUsersWidget extends StatefulWidget {
  const BlockedUsersWidget({super.key});

  static String routeName = 'BlockedUsers';
  static String routePath = '/blocked-users';

  @override
  State<BlockedUsersWidget> createState() => _BlockedUsersWidgetState();
}

class _BlockedUsersWidgetState extends State<BlockedUsersWidget> {
  late BlockedUsersModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<ApiCallResponse> _blockedFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BlockedUsersModel());
    _blockedFuture = BlockedUsersCall.call(token: currentAuthenticationToken);
  }

  Future<void> _refresh() async {
    final future = BlockedUsersCall.call(token: currentAuthenticationToken);
    setState(() => _blockedFuture = future);
    await future;
  }

  Future<void> _unblockUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unblock User'),
        content: const Text('Are you sure you want to unblock this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Unblock', style: TextStyle(color: FlutterFlowTheme.of(context).primary)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final response = await UnblockUserCall.call(
        token: currentAuthenticationToken,
        userId: userId,
      );
      if (!mounted) return;
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        _refresh();
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to unblock';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            onPressed: () => context.goNamedAuth(DashboardPageWidget.routeName, context.mounted),
          ),
          title: Text(
            'Blocked Users',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
              onPressed: _refresh,
              tooltip: 'Refresh',
            ),
          ],
          elevation: 2,
        ),
        body: FutureBuilder<ApiCallResponse>(
          future: _blockedFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading blocked users...',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ],
                ),
              );
            }

            final response = snapshot.data!;
            if (!response.succeeded) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: FlutterFlowTheme.of(context).error),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load blocked users',
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = getJsonField(response.jsonBody, r'''$.data''');
            final users = (getJsonField(data, r'''$.users''') as List?)?.toList() ?? [];
            final total = castToType<int>(getJsonField(data, r'''$.total''')) ?? users.length;

            if (users.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 80,
                        color: FlutterFlowTheme.of(context).secondaryText.withValues(alpha:0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No blocked users',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Blocked users will appear here. You can block users from their profile.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ResponsiveContainer(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                color: FlutterFlowTheme.of(context).primary,
                child: ListView.builder(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    ResponsiveBody.responsiveHorizontalPadding(context),
                    16,
                    ResponsiveBody.responsiveHorizontalPadding(context),
                    40,
                  ),
                itemCount: users.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '$total blocked user${total == 1 ? '' : 's'}',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                    );
                  }
                  final u = users[index - 1];
                  final userId = castToType<int>(getJsonField(u, r'''$.id''') ?? getJsonField(u, r'''$.user_id'''));
                  final name = getJsonField(u, r'''$.name''')?.toString() ??
                      '${getJsonField(u, r'''$.first_name''') ?? ''} ${getJsonField(u, r'''$.last_name''') ?? ''}'
                          .trim() ??
                      'User ${userId ?? index}';
                  final mobile = getJsonField(u, r'''$.mobile_number''')?.toString() ?? '';
                  final email = getJsonField(u, r'''$.email''')?.toString() ?? '';
                  final img = getJsonField(u, r'''$.profile_image''')?.toString();
                  final imgUrl = img != null && img.isNotEmpty && img != 'null'
                      ? (img.startsWith('http') ? img : '${ApiConfig.baseUrl}/$img')
                      : null;
                  final reason = getJsonField(u, r'''$.blocked_reason''')?.toString() ??
                      getJsonField(u, r'''$.reason_for_blocking''')?.toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                        backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
                        child: imgUrl == null
                            ? Icon(Icons.person, color: FlutterFlowTheme.of(context).primary, size: 28)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                  ),
                            ),
                          ),
                          if (userId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ID: $userId',
                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mobile.isNotEmpty ? mobile : (email.isNotEmpty ? email : '—'),
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                          if (reason != null && reason.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Reason: $reason',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      color: FlutterFlowTheme.of(context).error,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      trailing: userId != null
                          ? TextButton.icon(
                              icon: const Icon(Icons.lock_open_rounded, size: 18),
                              label: const Text('Unblock'),
                              onPressed: () => _unblockUser(userId),
                            )
                          : null,
                      onTap: userId != null
                          ? () => context.pushNamedAuth(
                                UserDetailsWidget.routeName,
                                context.mounted,
                                queryParameters: {'userId': userId.toString()},
                              )
                          : null,
                    ),
                  );
                },
              ),
            ),
            );
          },
        ),
      ),
    );
  }
}
