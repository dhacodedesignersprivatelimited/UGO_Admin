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
import 'kyc_pending_model.dart';
export 'kyc_pending_model.dart';

class KycPendingWidget extends StatefulWidget {
  const KycPendingWidget({super.key});

  static String routeName = 'KycPending';
  static String routePath = '/kyc-pending';

  @override
  State<KycPendingWidget> createState() => _KycPendingWidgetState();
}

class _KycPendingWidgetState extends State<KycPendingWidget> {
  late KycPendingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<ApiCallResponse> _kycFuture;
  final Set<int> _verifyingIds = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KycPendingModel());
    _kycFuture = KycPendingCall.call(token: currentAuthenticationToken);
  }

  Future<void> _refresh() async {
    final future = KycPendingCall.call(token: currentAuthenticationToken);
    setState(() {
      _kycFuture = future;
    });
    await future;
  }

  String _docUrl(dynamic path) {
    if (path == null || path.toString().isEmpty || path == 'null') return '';
    final p = path.toString();
    return p.startsWith('http') ? p : '${ApiConfig.baseUrl}/$p';
  }

  Future<void> _verifyDriver(int driverId, String status, String notes) async {
    if (_verifyingIds.contains(driverId)) return;
    setState(() => _verifyingIds.add(driverId));

    try {
      final response = await VerifyDocsCall.call(
        token: currentAuthenticationToken,
        driverId: driverId,
        verificationStatus: status,
        notes: notes,
      );

      if (!mounted) return;
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Driver KYC ${status == 'approved' ? 'Approved' : 'Rejected'}'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        _refresh();
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')?.toString() ?? 'Failed';
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
      if (mounted) setState(() => _verifyingIds.remove(driverId));
    }
  }

  void _showRejectDialog(int driverId) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject KYC'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'e.g. Documents unclear or invalid',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _verifyDriver(driverId, 'rejected', notesController.text.trim());
            },
            child: Text('Reject', style: TextStyle(color: FlutterFlowTheme.of(context).error)),
          ),
        ],
      ),
    );
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
            'KYC Pending',
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
          future: _kycFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary),
                    const SizedBox(height: 16),
                    Text('Loading KYC pending...', style: FlutterFlowTheme.of(context).bodyMedium),
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
                      Text('Failed to load KYC pending', style: FlutterFlowTheme.of(context).bodyLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                    ],
                  ),
                ),
              );
            }

            final data = getJsonField(response.jsonBody, r'''$.data''');
            final drivers = (getJsonField(data, r'''$.drivers''') as List?)?.toList() ?? [];
            final total = castToType<int>(getJsonField(data, r'''$.total''')) ?? drivers.length;

            if (drivers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, size: 80, color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.5)),
                      const SizedBox(height: 24),
                      Text('No pending KYC', style: FlutterFlowTheme.of(context).titleLarge.override(font: GoogleFonts.interTight(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      Text('All driver documents are verified.', textAlign: TextAlign.center, style: FlutterFlowTheme.of(context).bodyMedium.override(color: FlutterFlowTheme.of(context).secondaryText)),
                    ],
                  ),
                ),
              );
            }

            return ResponsiveContainer(
              padding: EdgeInsets.zero,
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: FlutterFlowTheme.of(context).primary,
                child: ListView.builder(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    ResponsiveBody.responsiveHorizontalPadding(context),
                    16,
                    ResponsiveBody.responsiveHorizontalPadding(context),
                    40,
                  ),
                itemCount: drivers.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '$total driver${total == 1 ? '' : 's'} pending KYC',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                    );
                  }

                  final d = drivers[index - 1];
                  final driverId = castToType<int>(getJsonField(d, r'''$.driver_id'''));
                  final name = getJsonField(d, r'''$.name''')?.toString() ?? 'Driver';
                  final phone = getJsonField(d, r'''$.phone''')?.toString() ?? '';
                  final uploadedDocs = getJsonField(d, r'''$.uploaded_docs''') as Map<String, dynamic>?;
                  final isLoading = driverId != null && _verifyingIds.contains(driverId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                                child: Icon(Icons.person, color: FlutterFlowTheme.of(context).primary),
                              ),
                              const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(name, style: FlutterFlowTheme.of(context).titleMedium.override(font: GoogleFonts.interTight(fontWeight: FontWeight.w600))),
                                      ),
                                      if (driverId != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('ID: $driverId', style: FlutterFlowTheme.of(context).labelSmall.override(font: GoogleFonts.inter(), color: FlutterFlowTheme.of(context).primary)),
                                        ),
                                    ],
                                  ),
                                  Text(phone, style: FlutterFlowTheme.of(context).bodySmall.override(color: FlutterFlowTheme.of(context).secondaryText)),
                                ],
                              ),
                            ),
                              if (driverId != null) ...[
                                TextButton.icon(
                                  icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.check_circle, size: 18, color: FlutterFlowTheme.of(context).primary),
                                  label: const Text('Approve'),
                                  onPressed: isLoading ? null : () => _verifyDriver(driverId, 'approved', 'All documents verified'),
                                ),
                                TextButton.icon(
                                  icon: Icon(Icons.cancel, size: 18, color: FlutterFlowTheme.of(context).error),
                                  label: Text('Reject', style: TextStyle(color: FlutterFlowTheme.of(context).error)),
                                  onPressed: isLoading ? null : () => _showRejectDialog(driverId),
                                ),
                              ],
                            ],
                          ),
                          if (uploadedDocs != null && uploadedDocs.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text('Documents', style: FlutterFlowTheme.of(context).labelMedium.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _docThumb('License Front', uploadedDocs['license_front_image']),
                                _docThumb('License Back', uploadedDocs['license_back_image']),
                                _docThumb('License', uploadedDocs['license_image']),
                                _docThumb('Aadhaar Front', uploadedDocs['aadhaar_front_image']),
                                _docThumb('Aadhaar Back', uploadedDocs['aadhaar_back_image']),
                                _docThumb('Aadhaar', uploadedDocs['aadhaar_image']),
                                _docThumb('PAN', uploadedDocs['pan_image']),
                                _docThumb('Address', uploadedDocs['address_proof']),
                              ],
                            ),
                          ],
                          if (driverId != null) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => context.pushNamedAuth(
                                DriverLicenseWidget.routeName,
                                context.mounted,
                                queryParameters: {'userId': driverId.toString()},
                              ),
                              child: Text('View full profile →', style: FlutterFlowTheme.of(context).bodySmall.override(color: FlutterFlowTheme.of(context).primary)),
                            ),
                          ],
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

  Widget _docThumb(String label, dynamic path) {
    final url = _docUrl(path);
    if (url.isEmpty) {
      return Tooltip(
        message: '$label: Not uploaded',
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 24),
        ),
      );
    }
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => _showImageDialog(label, url),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.grey.shade400)),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(String title, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: FlutterFlowTheme.of(context).titleMedium),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
