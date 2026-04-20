import '/core/auth/auth_util.dart';
import '/core/network/api_config.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/safe_network_avatar.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'driver_details_model.dart';
export 'driver_details_model.dart';

// --- Dynamic / admin formatting (top-level) ---

Map<String, dynamic>? _coerceMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

bool _isHiddenDriverFieldKey(String key) {
  final k = key.toLowerCase();
  if (k == 'password' || k == 'otp_hash') return true;
  const frags = [
    'fcm_token',
    'fcm',
    'device_token',
    'push_token',
    'apns',
    'refresh_token',
    'api_key',
    'secret_key',
  ];
  for (final f in frags) {
    if (k.contains(f)) return true;
  }
  return false;
}

String _titleCaseKey(String key) {
  return key
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

String _displayScalar(dynamic v) {
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty || s == 'null' ? '—' : s;
}

String _displayDateTime(dynamic v) {
  if (v == null) return '—';
  try {
    final dt = DateTime.tryParse(v.toString());
    if (dt == null) return _displayScalar(v);
    return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
  } catch (_) {
    return v.toString();
  }
}

bool _isMoneyKey(String kl) {
  if (kl.endsWith('_id')) return false;
  return kl.contains('fare') ||
      kl.contains('earning') ||
      kl.contains('balance') ||
      kl.contains('wallet') ||
      kl.contains('amount') ||
      kl.contains('payout') ||
      kl.endsWith('_inr');
}

bool _isNumericLike(dynamic v) {
  if (v is num) return true;
  if (v is String) return double.tryParse(v.trim()) != null;
  return false;
}

String _formatDriverScalar(String key, dynamic value) {
  final kl = key.toLowerCase();
  if (kl.contains('_at') ||
      kl.contains('_time') ||
      kl == 'last_login' ||
      kl == 'created_at' ||
      kl == 'updated_at') {
    return _displayDateTime(value);
  }
  if (_isMoneyKey(kl) && _isNumericLike(value)) {
    final n = value is num ? value.toDouble() : double.parse(value.toString());
    final fmt = NumberFormat('#,##0.00', 'en_IN');
    return '₹${fmt.format(n)}';
  }
  if (value is bool) return value ? 'Yes' : 'No';
  return _displayScalar(value);
}

bool _isImageKey(String key) {
  final k = key.toLowerCase();
  return k.contains('profile_image') ||
      k.contains('_image') ||
      k == 'photo' ||
      k.contains('thumbnail');
}

bool _looksLikeImagePath(String s) {
  final lower = s.toLowerCase();
  if (lower.startsWith('http')) {
    return RegExp(r'\.(jpg|jpeg|png|gif|webp)(\?|#|$)', caseSensitive: false)
        .hasMatch(lower);
  }
  return lower.contains('upload') &&
      RegExp(r'\.(jpg|jpeg|png|gif|webp)', caseSensitive: false).hasMatch(lower);
}

/// Admin-facing empty / missing value (avoid raw "null" or em dash in UI).
String _elideForUi(String s) {
  final t = s.trim();
  if (t.isEmpty || t == '—' || t == 'null') return 'Not provided';
  return t;
}

bool _isUncopyable(String? s) {
  if (s == null) return true;
  final t = s.trim();
  return t.isEmpty ||
      t == 'null' ||
      t == '—' ||
      t == 'Not provided';
}

String _friendlyLabelForKey(String key) {
  const map = <String, String>{
    'created_at': 'Profile created',
    'updated_at': 'Last updated',
    'last_login': 'Last sign-in',
    'last_seen': 'Last seen',
    'device_id': 'Device reference',
    'gender': 'Gender',
    'date_of_birth': 'Date of birth',
    'dob': 'Date of birth',
    'blood_group': 'Blood group',
    'emergency_contact': 'Emergency contact',
    'referral_code': 'Referral code',
    'referred_by': 'Referred by',
    'commission_rate': 'Commission rate',
    'payout_cycle': 'Payout cycle',
    'tax_id': 'Tax ID',
    'gst_number': 'GST number',
    'pan_number': 'PAN number',
    'aadhaar_number': 'Aadhaar number',
    'verification_status': 'Verification status',
    'notes': 'Internal notes',
    'remark': 'Remarks',
    'status': 'Record status',
    'user_id': 'Linked user ID',
    'parent_id': 'Parent account',
    'service_area': 'Service area',
    'preferred_language': 'Preferred language',
    'timezone': 'Time zone',
    'country_code': 'Country code',
    'postal_code': 'Postal code',
    'pincode': 'PIN code',
    'zip': 'Postal code',
  };
  if (map.containsKey(key)) return map[key]!;
  return _titleCaseKey(key);
}

String _kycStatusPhrase(String kycLower) {
  switch (kycLower) {
    case 'approved':
      return 'KYC · Verified';
    case 'pending':
      return 'KYC · Pending review';
    case 'rejected':
    case 'declined':
      return 'KYC · Not approved';
    default:
      if (kycLower.isEmpty || kycLower == 'null') return 'KYC · Unknown';
      return 'KYC · ${_titleCaseKey(kycLower)}';
  }
}

class DriverDetailsWidget extends StatefulWidget {
  const DriverDetailsWidget({
    super.key,
    required this.driverId,
    this.openDocumentsOnLoad = false,
  });

  final int? driverId;
  final bool openDocumentsOnLoad;

  static String routeName = 'DriverDetails';
  static String routePath = '/driver-details';

  @override
  State<DriverDetailsWidget> createState() => _DriverDetailsWidgetState();
}

class _DriverDetailsWidgetState extends State<DriverDetailsWidget> {
  late DriverDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _documentsSectionKey = GlobalKey();

  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  bool _didAutoScrollToDocuments = false;
  Map<String, dynamic>? _driverData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverDetailsModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDriver());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchDriver() async {
    if (widget.driverId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid driver ID';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await GetDriverByIdCall.call(
        id: widget.driverId,
        token: currentAuthenticationToken,
      );
      if (!mounted) return;
      if (response.succeeded) {
        final data = GetDriverByIdCall.data(response.jsonBody);
        setState(() {
          _driverData = data != null ? Map<String, dynamic>.from(data) : null;
          _isLoading = false;
        });
        _scheduleDocumentsScrollIfRequested();
      } else {
        setState(() {
          _errorMessage = getJsonField(response.jsonBody, r'''$.message''')
              ?.toString() ??
              'Failed to load driver';
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

  void _scheduleDocumentsScrollIfRequested() {
    if (!widget.openDocumentsOnLoad || _didAutoScrollToDocuments) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didAutoScrollToDocuments) return;
      final targetContext = _documentsSectionKey.currentContext;
      if (targetContext == null) return;
      _didAutoScrollToDocuments = true;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  String _string(String path) =>
      getJsonField(_driverData ?? {}, path)?.toString() ?? '';

  bool _bool(String path, {bool fallback = false}) {
    final value = getJsonField(_driverData ?? {}, path);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return fallback;
  }

  String _safeUrl(String raw) {
    if (raw.isEmpty || raw == 'null') return '';
    if (raw.startsWith('http')) return raw;
    return '${ApiConfig.baseUrl}/${raw.replaceFirst(RegExp(r'^/'), '')}';
  }

  Future<void> _copy(String label, String text) async {
    if (_isUncopyable(text)) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Keys already shown in curated sections or document cards.
  static const Set<String> _curatedTopLevelKeys = {
    'id',
    'first_name',
    'last_name',
    'mobile_number',
    'email',
    'profile_image',
    'driver_rating',
    'total_rides_completed',
    'total_earnings',
    'wallet_balance',
    'kyc_status',
    'is_active',
    'is_online',
    'vehicle_number',
    'license_number',
    'address',
    'city',
    'state',
    'current_location_latitude',
    'current_location_longitude',
    'bank_account_number',
    'bank_ifsc_code',
    'bank_holder_name',
    'license_front_image',
    'license_back_image',
    'aadhaar_front_image',
    'aadhaar_back_image',
    'pan_image',
    'vehicle_image',
    'rc_front_image',
    'rc_back_image',
    'adminVehicle',
    'vehicle',
    'driver',
  };

  Future<void> _toggleOnline(bool nextValue) async {
    if (widget.driverId == null || _isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    final response = await UpdateDriverCall.call(
      id: widget.driverId!,
      token: currentAuthenticationToken,
      isOnline: nextValue,
    );
    if (!mounted) return;
    setState(() => _isUpdatingStatus = false);
    if (response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated!')),
      );
      await _fetchDriver();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  // --- UI Helpers ---

  Widget _buildStatusBadge(String text, Color color, {bool onDark = false}) {
    if (onDark) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
        ),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: FlutterFlowTheme.of(context).labelSmall.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.14),
              FlutterFlowTheme.of(context).secondaryBackground,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.9),
                    accent.withValues(alpha: 0.65),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              _elideForUi(value.isEmpty ? '—' : value),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    String? copyValue,
  }) {
    final display = _elideForUi(value.isEmpty ? '—' : value);
    final canCopy = copyValue != null && !_isUncopyable(copyValue);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15),
                  FlutterFlowTheme.of(context).primary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: FlutterFlowTheme.of(context).primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.3,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              tooltip: 'Copy',
              icon: Icon(
                Icons.copy_rounded,
                size: 20,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              onPressed: () => _copy(label, copyValue),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, int delayMs) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF7A00),
                      const Color(0xFFFFB347),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.alternate.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delayMs.ms).slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          delay: delayMs.ms,
          curve: Curves.easeOut,
        );
  }

  List<MapEntry<String, dynamic>> _extraFieldEntries(Map<String, dynamic> data) {
    return data.entries
        .where((e) =>
            !_curatedTopLevelKeys.contains(e.key) &&
            !_isHiddenDriverFieldKey(e.key))
        .where((e) {
          final v = e.value;
          if (v == null) return false;
          if (v is Map && (_coerceMap(v)?.isEmpty ?? true)) return false;
          if (v is List && v.isEmpty) return false;
          final s = v.toString().trim();
          return s.isNotEmpty && s != 'null';
        })
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  bool _hasExtraFields(Map<String, dynamic> data) =>
      _extraFieldEntries(data).isNotEmpty;

  List<Widget> _buildDynamicFieldTiles(Map<String, dynamic> data) {
    final theme = FlutterFlowTheme.of(context);
    final entries = _extraFieldEntries(data);
    if (entries.isEmpty) return [];

    return entries.map((e) {
      final key = e.key;
      final value = e.value;
      final label = _friendlyLabelForKey(key);

      if (value is Map) {
        final m = _coerceMap(value)!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
              title: Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: theme.primaryText,
                ),
              ),
              children: m.entries
                  .where((x) => !_isHiddenDriverFieldKey(x.key))
                  .map((x) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 128,
                              child: Text(
                                _friendlyLabelForKey(x.key),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: theme.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _elideForUi(_formatDriverScalar(x.key, x.value)),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      }

      if (value is List) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.every((e) => e is! Map && e is! List)
                      ? value.map((e) => e.toString()).join(', ')
                      : '${value.length} linked records',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final strVal = value.toString().trim();
      if (_isImageKey(key) || _looksLikeImagePath(strVal)) {
        final url = _safeUrl(strVal);
        if (url.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: theme.alternate.withValues(alpha: 0.35),
                          child: Icon(Icons.broken_image_outlined,
                              color: theme.secondaryText),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showImageDialog(label, url),
                      icon: Icon(Icons.open_in_new_rounded,
                          size: 16, color: theme.primary),
                      label: Text(
                        'Open',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: theme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final formatted = _formatDriverScalar(key, value);
      final shown = _elideForUi(formatted);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                shown,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (key.contains('phone') ||
                key.contains('mobile') ||
                key.contains('email') ||
                key == 'id')
              IconButton(
                tooltip: 'Copy',
                icon: Icon(Icons.copy_rounded,
                    size: 18, color: theme.secondaryText),
                onPressed: _isUncopyable(formatted) || shown == 'Not provided'
                    ? null
                    : () => _copy(label, formatted),
              ),
          ],
        ),
      );
    }).toList();
  }

  void _showExtraProfileDetailsSheet() {
    final data = _driverData;
    if (data == null || !_hasExtraFields(data)) return;
    final theme = FlutterFlowTheme.of(context);
    final tiles = _buildDynamicFieldTiles(data);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.58,
          minChildSize: 0.38,
          maxChildSize: 0.94,
          builder: (_, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More profile details',
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: theme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Only shown here when the record has extra fields.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.alternate.withValues(alpha: 0.5)),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    children: [
                      ...tiles,
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageDialog(String title, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6,
                  color: Colors.black87,
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(color: Colors.white54),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                color: FlutterFlowTheme.of(context).alternate, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              'Image not available',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard(String title, String rawPath) {
    final url = _safeUrl(rawPath);
    final hasUrl = url.isNotEmpty;
    return Container(
      width: MediaQuery.of(context).size.width > 600 ? 320 : double.infinity,
      margin: const EdgeInsets.only(bottom: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FlutterFlowTheme.of(context).primary.withValues(alpha:0.8),
                    FlutterFlowTheme.of(context).primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
            ),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasUrl ? 'Uploaded & Secured' : 'Not uploaded',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    color: hasUrl
                        ? const Color(0xFF2E7D32) // Success green
                        : FlutterFlowTheme.of(context).error,
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          if (hasUrl)
            FFButtonWidget(
              onPressed: () => _showImageDialog(title, url),
              text: 'View',
              options: FFButtonOptions(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  color: FlutterFlowTheme.of(context).primary,
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _documentCardsForDriver(Map<String, dynamic> d) {
    const known = <(String, String)>[
      ('License front', 'license_front_image'),
      ('License back', 'license_back_image'),
      ('Aadhaar front', 'aadhaar_front_image'),
      ('Aadhaar back', 'aadhaar_back_image'),
      ('PAN card', 'pan_image'),
      ('Vehicle photo', 'vehicle_image'),
      ('RC front', 'rc_front_image'),
      ('RC back', 'rc_back_image'),
    ];
    final seen = <String>{};
    final out = <Widget>[];
    for (final pair in known) {
      seen.add(pair.$2);
      out.add(_buildDocCard(pair.$1, d[pair.$2]?.toString() ?? ''));
    }
    for (final k in d.keys) {
      if (seen.contains(k)) continue;
      final kl = k.toLowerCase();
      if (!kl.contains('image') && !kl.endsWith('_photo')) continue;
      final v = d[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isEmpty || s == 'null') continue;
      out.add(_buildDocCard(_titleCaseKey(k), s));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final photoRaw = _string(r'''$.profile_image''');
    final photoUrl = photoRaw.isNotEmpty && photoRaw != 'null'
        ? (photoRaw.startsWith('http')
        ? photoRaw
        : '${ApiConfig.baseUrl}/${photoRaw.replaceFirst(RegExp(r'^/'), '')}')
        : '';

    final name = '${_string(r'''$.first_name''')} ${_string(r'''$.last_name''')}'.trim();
    final phone = _string(r'''$.mobile_number''');
    final email = _string(r'''$.email''');
    final vehicle = _string(r'''$.adminVehicle.vehicle_name''');
    final vehicleNumber = _string(r'''$.vehicle_number''');
    final rating = _string(r'''$.driver_rating''');
    final totalRides = _string(r'''$.total_rides_completed''');
    final earningsRaw = _string(r'''$.total_earnings''');
    final walletBal = _string(r'''$.wallet_balance''');
    final kycStatus = _string(r'''$.kyc_status''').toLowerCase();
    final isActive = _bool(r'''$.is_active''');
    final isOnline = _bool(r'''$.is_online''');

    var moneyValue = '—';
    var moneyLabel = 'Lifetime earnings';
    final eNum = double.tryParse(earningsRaw);
    if (eNum != null) {
      moneyValue =
          '₹${NumberFormat('#,##0.00', 'en_IN').format(eNum)}';
    } else if (earningsRaw.isNotEmpty && earningsRaw != 'null') {
      moneyValue = '₹$earningsRaw';
    } else if (walletBal.isNotEmpty && walletBal != 'null') {
      moneyValue = _formatDriverScalar('wallet_balance', walletBal);
      moneyLabel = 'Wallet balance';
    }

    final apiDriverId = _string(r'''$.id''');
    final driverIdDisplay = (apiDriverId.isNotEmpty && apiDriverId != 'null')
        ? apiDriverId
        : (widget.driverId?.toString() ?? '—');
    final driverIdCopy = (apiDriverId.isNotEmpty && apiDriverId != 'null')
        ? apiDriverId
        : (widget.driverId?.toString() ?? '');
    final lat = _string(r'''$.current_location_latitude''');
    final lng = _string(r'''$.current_location_longitude''');
    final latLngCombined = (lat.isNotEmpty &&
            lat != 'null' &&
            lng.isNotEmpty &&
            lng != 'null')
        ? '$lat, $lng'
        : '';

    // Determine colors
    final kycColor = kycStatus == 'approved'
        ? const Color(0xFF2E7D32)
        : kycStatus == 'pending'
            ? const Color(0xFFF57C00)
            : FlutterFlowTheme.of(context).error;

    final theme = FlutterFlowTheme.of(context);

    var ratingDisplay = rating.isNotEmpty && rating != 'null' ? rating : 'Not provided';
    final ratingNum = double.tryParse(rating);
    if (ratingNum != null) {
      final dec = ratingNum == ratingNum.roundToDouble() ? 0 : 1;
      ratingDisplay = '${ratingNum.toStringAsFixed(dec)} / 5';
    }

    var ridesDisplay =
        totalRides.isNotEmpty && totalRides != 'null' ? totalRides : 'Not provided';
    final ridesInt = int.tryParse(totalRides);
    if (ridesInt != null) {
      ridesDisplay = NumberFormat.decimalPattern('en_IN').format(ridesInt);
    }

    return AdminPopScope(
      fallbackRouteName: AllusersWidget.routeName,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF4F6FA),
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF7A00),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Driver',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            if (_driverData != null && _hasExtraFields(_driverData!))
              IconButton(
                tooltip: 'More profile details',
                icon: const Icon(Icons.article_outlined, color: Colors.white),
                onPressed: _isLoading ? null : _showExtraProfileDetailsSheet,
              ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _isLoading ? null : _fetchDriver,
            ),
          ],
        ),
        body: _isLoading
            ? Center(
            child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary)
        )
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, size: 64, color: FlutterFlowTheme.of(context).error),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center, style: FlutterFlowTheme.of(context).titleMedium),
                const SizedBox(height: 24),
                FFButtonWidget(
                  onPressed: _fetchDriver,
                  text: 'Try Again',
                  options: FFButtonOptions(
                    height: 44,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _fetchDriver,
          color: FlutterFlowTheme.of(context).primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO PROFILE SECTION
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF8A00),
                        Color(0xFFFF6D00),
                        Color(0xFFE65100),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7A00).withValues(alpha: 0.38),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'driver_photo_${widget.driverId}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SafeNetworkAvatar(
                            imageUrl: photoUrl,
                            radius: 50,
                            placeholderIcon: Icons.person,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name.isNotEmpty ? name : 'Unknown Driver',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _elideForUi(phone.isEmpty || phone == 'null' ? '—' : phone),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                      if (email.isNotEmpty && email != 'null') ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _buildStatusBadge(_kycStatusPhrase(kycStatus), kycColor, onDark: true),
                          _buildStatusBadge(
                            isActive ? 'Account active' : 'Account disabled',
                            isActive
                                ? const Color(0xFF2E7D32)
                                : FlutterFlowTheme.of(context).error,
                            onDark: true,
                          ),
                          _buildStatusBadge(
                            isOnline ? 'On duty' : 'Off duty',
                            isOnline
                                ? const Color(0xFF00C853)
                                : const Color(0xFFB0BEC5),
                            onDark: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      if (kycStatus == 'pending')
                        FFButtonWidget(
                          onPressed: () => context.goNamedAuth(
                            KycPendingWidget.routeName,
                            context.mounted,
                            queryParameters: {'driverId': widget.driverId.toString()},
                          ),
                          text: 'Review Pending KYC',
                          icon: const Icon(Icons.fact_check_rounded, size: 20),
                          options: FFButtonOptions(
                            height: 48,
                            width: 250,
                            color: Colors.white,
                            textStyle: GoogleFonts.interTight(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: const Color(0xFFE65100),
                            ),
                            borderRadius: BorderRadius.circular(24),
                            elevation: 4,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2000.ms, color: Colors.orange.shade100)
                      else if (kycStatus == 'approved')
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 320),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Online status',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              isOnline ? 'Visible to dispatch' : 'Not accepting rides',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF2E7D32),
                            inactiveThumbColor: Colors.white70,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                            value: isOnline,
                            onChanged: _isUpdatingStatus ? null : (val) => _toggleOnline(val),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

                // MAIN CONTENT PADDING
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // 2. QUICK STATS GRID
                      Row(
                        children: [
                          _buildQuickStat(
                            Icons.star_rounded,
                            'Rating',
                            ratingDisplay,
                            const Color(0xFFFBC02D),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickStat(
                            Icons.route_rounded,
                            'Trips completed',
                            ridesDisplay,
                            FlutterFlowTheme.of(context).primary,
                          ),
                          const SizedBox(width: 12),
                          _buildQuickStat(
                            Icons.payments_rounded,
                            moneyLabel,
                            moneyValue,
                            const Color(0xFF2E7D32),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),

                      // 3. STAGGERED SECTIONS
                      _buildSection('Contact & reference', [
                        _buildInfoRow(
                          Icons.tag_rounded,
                          'Driver ID',
                          driverIdDisplay,
                          copyValue: driverIdCopy.isNotEmpty ? driverIdCopy : null,
                        ),
                        _buildInfoRow(
                          Icons.phone_iphone_rounded,
                          'Phone',
                          phone,
                          copyValue: (phone.isNotEmpty && phone != 'null') ? phone : null,
                        ),
                        if (email.isNotEmpty && email != 'null')
                          _buildInfoRow(
                            Icons.email_rounded,
                            'Email',
                            email,
                            copyValue: email,
                          ),
                      ], 180),

                      _buildSection('Vehicle', [
                        _buildInfoRow(
                          Icons.directions_car_filled,
                          'Vehicle model',
                          vehicle,
                        ),
                        _buildInfoRow(
                          Icons.confirmation_number,
                          'Registration number',
                          vehicleNumber,
                          copyValue: (vehicleNumber.isNotEmpty &&
                                  vehicleNumber != 'null')
                              ? vehicleNumber
                              : null,
                        ),
                        _buildInfoRow(
                          Icons.category_rounded,
                          'Service category',
                          _string(r'''$.adminVehicle.ride_category'''),
                        ),
                        _buildInfoRow(
                          Icons.work_rounded,
                          'Luggage capacity',
                          _string(r'''$.adminVehicle.luggage_capacity'''),
                        ),
                      ], 200),

                      _buildSection('Address & last location', [
                        _buildInfoRow(
                          Icons.badge_rounded,
                          'Driving licence number',
                          _string(r'''$.license_number'''),
                          copyValue: _string(r'''$.license_number'''),
                        ),
                        _buildInfoRow(
                          Icons.home_work_rounded,
                          'Street address',
                          _string(r'''$.address'''),
                        ),
                        _buildInfoRow(
                          Icons.location_city_rounded,
                          'City',
                          _string(r'''$.city'''),
                        ),
                        _buildInfoRow(
                          Icons.flag_rounded,
                          'State',
                          _string(r'''$.state'''),
                        ),
                        _buildInfoRow(
                          Icons.explore_rounded,
                          'Latitude',
                          lat,
                          copyValue: (lat.isNotEmpty && lat != 'null') ? lat : null,
                        ),
                        _buildInfoRow(
                          Icons.explore_outlined,
                          'Longitude',
                          lng,
                          copyValue: (lng.isNotEmpty && lng != 'null') ? lng : null,
                        ),
                        if (latLngCombined.isNotEmpty)
                          _buildInfoRow(
                            Icons.content_copy_rounded,
                            'Coordinates (for maps)',
                            latLngCombined,
                            copyValue: latLngCombined,
                          ),
                      ], 300),

                      _buildSection('Payout bank account', [
                        _buildInfoRow(
                          Icons.account_balance,
                          'Account Number',
                          _string(r'''$.bank_account_number'''),
                          copyValue: _string(r'''$.bank_account_number'''),
                        ),
                        _buildInfoRow(
                          Icons.confirmation_num_rounded,
                          'IFSC Code',
                          _string(r'''$.bank_ifsc_code'''),
                          copyValue: _string(r'''$.bank_ifsc_code'''),
                        ),
                        _buildInfoRow(
                          Icons.person,
                          'Account Holder',
                          _string(r'''$.bank_holder_name'''),
                          copyValue: _string(r'''$.bank_holder_name'''),
                        ),
                      ], 400),

                      if (_driverData != null) ...[
                        Container(
                          key: _documentsSectionKey,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: theme.alternate.withValues(alpha: 0.45)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF7A00).withValues(alpha: 0.08),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFFF7A00),
                                          Color(0xFFFFB347),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Documents',
                                      style: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: theme.primaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(height: 1, color: theme.alternate.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.start,
                                children: _documentCardsForDriver(_driverData!),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.05, end: 0),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}