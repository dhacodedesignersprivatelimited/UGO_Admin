import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_details_model.dart';
export 'user_details_model.dart';

class UserDetailsWidget extends StatefulWidget {
  const UserDetailsWidget({super.key, required this.userId});

  final int? userId;

  static String routeName = 'UserDetails';
  static String routePath = '/user-details';

  @override
  State<UserDetailsWidget> createState() => _UserDetailsWidgetState();
}

class _UserDetailsWidgetState extends State<UserDetailsWidget> {
  late UserDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserDetailsModel());
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchUserData());
  }

  Future<void> _fetchUserData() async {
    if (widget.userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid user ID';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await GetUserByIdCall.call(
        id: widget.userId!,
        token: currentAuthenticationToken,
      );
      if (!mounted) return;
      if (response.succeeded) {
        final data = GetUserByIdCall.data(response.jsonBody);
        setState(() {
          _userData = data != null ? Map<String, dynamic>.from(data) : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = getJsonField(response.jsonBody, r'''$.message''')
                  ?.toString() ??
              'Failed to load user';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? '—',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamedAuth(AllusersWidget.routeName, context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 28),
            onPressed: _handleBack,
          ),
          title: Text(
            'User Details',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 20,
                ),
          ),
          elevation: 2,
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading user details...',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48,
                              color: FlutterFlowTheme.of(context).error),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          FFButtonWidget(
                            onPressed: _fetchUserData,
                            text: 'Retry',
                            options: FFButtonOptions(
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                FlutterFlowTheme.of(context).primary,
                                FlutterFlowTheme.of(context)
                                    .primary
                                    .withValues(alpha:0.8),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildProfileAvatar(),
                              const SizedBox(height: 16),
                              Text(
                                '${getJsonField(_userData, r'''$.first_name''') ?? ''} ${getJsonField(_userData, r'''$.last_name''') ?? ''}'
                                    .trim()
                                    .isEmpty
                                    ? 'User'
                                    : '${getJsonField(_userData, r'''$.first_name''') ?? ''} ${getJsonField(_userData, r'''$.last_name''') ?? ''}'
                                        .trim(),
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold),
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                              ),
                              if (widget.userId != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'ID: ${widget.userId}',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              _buildStatusChip(),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: -0.04, end: 0, curve: Curves.easeOutCubic),
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Information',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold),
                                    ),
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.phone_rounded,
                                'Mobile',
                                getJsonField(_userData, r'''$.mobile_number''')
                                    ?.toString(),
                              ),
                              _buildInfoRow(
                                Icons.email_rounded,
                                'Email',
                                getJsonField(_userData, r'''$.email''')
                                    ?.toString(),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Account',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold),
                                    ),
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.star_rounded,
                                'Rating',
                                getJsonField(_userData, r'''$.overall_rating''')
                                    ?.toString(),
                              ),
                              _buildInfoRow(
                                Icons.local_taxi_rounded,
                                'Total Rides',
                                getJsonField(_userData, r'''$.total_rides''')
                                    ?.toString(),
                              ),
                              _buildInfoRow(
                                Icons.badge_rounded,
                                'Account Type',
                                getJsonField(_userData, r'''$.account_type''')
                                    ?.toString(),
                              ),
                              _buildInfoRow(
                                Icons.calendar_today_rounded,
                                'Joined',
                                _formatDate(getJsonField(
                                    _userData, r'''$.created_at''')),
                              ),
                              _buildInfoRow(
                                Icons.login_rounded,
                                'Last Login',
                                _formatDate(
                                    getJsonField(_userData, r'''$.last_login''')),
                              ),
                              const SizedBox(height: 24),
                              _buildBlockUnblockButton(),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 350.ms, delay: 80.ms)
                            .slideY(begin: 0.05, end: 0, delay: 80.ms, curve: Curves.easeOutCubic),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildBlockUnblockButton() {
    final isBlocked = getJsonField(_userData, r'''$.is_blocked''') == true;
    final userId = castToType<int>(getJsonField(_userData, r'''$.id'''));
    if (userId == null) return const SizedBox.shrink();

    return isBlocked
        ? SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isBlockActionLoading ? null : () => _unblockUser(userId),
              icon: _isBlockActionLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    )
                  : Icon(Icons.lock_open_rounded, color: FlutterFlowTheme.of(context).primary),
              label: Text(
                _isBlockActionLoading ? 'Processing...' : 'Unblock User',
                style: TextStyle(color: FlutterFlowTheme.of(context).primary),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: FlutterFlowTheme.of(context).primary),
              ),
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isBlockActionLoading ? null : () => _showBlockDialog(userId),
              icon: _isBlockActionLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FlutterFlowTheme.of(context).error,
                      ),
                    )
                  : Icon(Icons.block_rounded, color: FlutterFlowTheme.of(context).error),
              label: Text(
                _isBlockActionLoading ? 'Processing...' : 'Block User',
                style: TextStyle(color: FlutterFlowTheme.of(context).error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: FlutterFlowTheme.of(context).error),
              ),
            ),
          );
  }

  bool _isBlockActionLoading = false;

  void _showBlockDialog(int userId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enter the reason for blocking this user:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Fraudulent activity',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _blockUser(userId, reasonController.text.trim());
            },
            child: Text('Block', style: TextStyle(color: FlutterFlowTheme.of(context).error)),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser(int userId, String reason) async {
    setState(() => _isBlockActionLoading = true);
    try {
      final response = await BlockUserCall.call(
        token: currentAuthenticationToken,
        userId: userId,
        reasonForBlocking: reason.isEmpty ? 'Blocked by admin' : reason,
      );
      if (!mounted) return;
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User blocked successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        _fetchUserData();
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to block user';
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
    } finally {
      if (mounted) setState(() => _isBlockActionLoading = false);
    }
  }

  Future<void> _unblockUser(int userId) async {
    setState(() => _isBlockActionLoading = true);
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
        _fetchUserData();
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to unblock user';
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
    } finally {
      if (mounted) setState(() => _isBlockActionLoading = false);
    }
  }

  Widget _buildProfileAvatar() {
    final img = getJsonField(_userData, r'''$.profile_image''')?.toString();
    final imgUrl = img != null && img.isNotEmpty && img != 'null'
        ? (img.startsWith('http') ? img : '${ApiConfig.baseUrl}/$img')
        : null;

    return CircleAvatar(
      radius: 56,
      backgroundColor: Colors.white.withValues(alpha:0.3),
      child: imgUrl != null && imgUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imgUrl,
                width: 112,
                height: 112,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            )
          : const Icon(Icons.person, size: 56, color: Colors.white),
    );
  }

  Widget _buildStatusChip() {
    final isBlocked = getJsonField(_userData, r'''$.is_blocked''') == true;
    final status = getJsonField(_userData, r'''$.account_status''')?.toString() ??
        (isBlocked ? 'blocked' : 'active');

    Color bgColor;
    Color textColor;
    if (isBlocked || status.toLowerCase() == 'blocked') {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
    } else {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: textColor,
            ),
      ),
    );
  }

  String? _formatDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (str.isEmpty) return null;
    try {
      final dt = DateTime.tryParse(str);
      return dt != null
          ? '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}'
          : str;
    } catch (_) {
      return str;
    }
  }
}
