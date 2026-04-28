import '/core/auth/auth_util.dart';
import '/core/network/api_config.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/safe_network_avatar.dart';
import '/shared/widgets/responsive_body.dart';
import '/index.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Unblock User',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
          ),
        ),
        content: Text(
          'Are you sure you want to restore this user\'s access to the platform?',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unblock User'),
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
            behavior: SnackBarBehavior.floating,
          ),
        );
        _refresh();
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')?.toString() ?? 'Failed to unblock';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
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
    return AdminPopScope(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            onPressed: () => context.goNamedAuth(DashboardScreen.routeName, context.mounted),
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
              tooltip: 'Refresh List',
            ),
          ],
          elevation: 0,
        ),
        body: FutureBuilder<ApiCallResponse>(
          future: _blockedFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fetching blocked accounts...',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline_rounded, size: 48, color: FlutterFlowTheme.of(context).error),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load data',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There was an issue connecting to the server.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Try Again'),
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                        ),
                        child: Icon(
                          Icons.gpp_good_rounded,
                          size: 64,
                          color: FlutterFlowTheme.of(context).success,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No blocked users',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your platform looks clean. Users blocked by administrators will appear here.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ResponsiveContainer(
              maxWidth: 800,
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                color: FlutterFlowTheme.of(context).primary,
                child: ListView.builder(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    ResponsiveBody.responsiveHorizontalPadding(context) == 0 ? 16 : ResponsiveBody.responsiveHorizontalPadding(context),
                    24,
                    ResponsiveBody.responsiveHorizontalPadding(context) == 0 ? 16 : ResponsiveBody.responsiveHorizontalPadding(context),
                    40,
                  ),
                  itemCount: users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Icon(Icons.block_rounded, size: 20, color: FlutterFlowTheme.of(context).secondaryText),
                            const SizedBox(width: 8),
                            Text(
                              '$total Restricted Account${total == 1 ? '' : 's'}',
                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final u = users[index - 1];
                    final userId = castToType<int>(getJsonField(u, r'''$.id''') ?? getJsonField(u, r'''$.user_id'''));
                    final name = getJsonField(u, r'''$.name''')?.toString() ??
                        '${getJsonField(u, r'''$.first_name''') ?? ''} ${getJsonField(u, r'''$.last_name''') ?? ''}'.trim();
                    final finalName = name.isNotEmpty ? name : 'User ${userId ?? index}';

                    final mobile = getJsonField(u, r'''$.mobile_number''')?.toString() ?? '';
                    final email = getJsonField(u, r'''$.email''')?.toString() ?? '';
                    final img = getJsonField(u, r'''$.profile_image''')?.toString();
                    final imgUrl = img != null && img.isNotEmpty && img != 'null'
                        ? (img.startsWith('http') ? img : '${ApiConfig.baseUrl}/$img')
                        : null;
                    final reason = getJsonField(u, r'''$.blocked_reason''')?.toString() ??
                        getJsonField(u, r'''$.reason_for_blocking''')?.toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Avatar, Info, Action
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: userId != null
                                      ? () => context.pushNamedAuth(
                                    UserDetailsWidget.routeName,
                                    context.mounted,
                                    queryParameters: {'userId': userId.toString()},
                                  )
                                      : null,
                                  child: SafeNetworkAvatar(
                                    imageUrl: imgUrl ?? '',
                                    radius: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              finalName,
                                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                                color: FlutterFlowTheme.of(context).primaryText,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (userId != null)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'ID: $userId',
                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                    color: FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (mobile.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.phone_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                            const SizedBox(width: 4),
                                            Text(
                                              mobile,
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (email.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Row(
                                            children: [
                                              Icon(Icons.email_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  email,
                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (userId != null)
                                  FilledButton.tonalIcon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: FlutterFlowTheme.of(context).success.withValues(alpha: 0.1),
                                      foregroundColor: FlutterFlowTheme.of(context).success,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.lock_open_rounded, size: 18),
                                    label: Text(
                                      'Unblock',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                    onPressed: () => _unblockUser(userId),
                                  ),
                              ],
                            ),

                            // Bottom Row: Reason Box
                            if (reason != null && reason.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: FlutterFlowTheme.of(context).error,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Reason for Restriction',
                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                              color: FlutterFlowTheme.of(context).error,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            reason,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).primaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
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