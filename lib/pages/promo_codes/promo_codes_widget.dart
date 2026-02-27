import '/auth/custom_auth/auth_util.dart';
import '/components/admin_drawer.dart';
import '/components/responsive_body.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'promo_codes_model.dart';
export 'promo_codes_model.dart';

class PromoCodesWidget extends StatefulWidget {
  const PromoCodesWidget({super.key});

  static String routeName = 'promoCodes';
  static String routePath = '/promoCodes';

  @override
  State<PromoCodesWidget> createState() => _PromoCodesWidgetState();
}

class _PromoCodesWidgetState extends State<PromoCodesWidget> {
  late PromoCodesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loadingPromos = true;
  int? _adminId = 1;
  List<dynamic> _promoCodes = [];
  final Set<int> _deactivatingIds = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PromoCodesModel());

    _model.codeNameTextController ??= TextEditingController();
    _model.codeNameFocusNode ??= FocusNode();

    _model.discountValueTextController ??= TextEditingController();
    _model.discountValueFocusNode ??= FocusNode();

    _model.maxDiscountTextController ??= TextEditingController();
    _model.maxDiscountFocusNode ??= FocusNode();

    _model.expiryDateTextController ??= TextEditingController(text: '2025-12-31');
    _model.expiryDateFocusNode ??= FocusNode();

    _model.usageLimitTextController ??= TextEditingController(text: '1000');
    _model.usageLimitFocusNode ??= FocusNode();

    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loadingPromos = true);

    try {
      // Fetch admin profile for created_by_admin_id
      final profileResp = await GetProfileCall.call(token: currentAuthenticationToken);
      if (profileResp.succeeded) {
        final data = getJsonField(profileResp.jsonBody ?? '', r'''$.data''');
        final id = getJsonField(data, r'''$.id''');
        if (id != null) {
          _adminId = castToType<int>(id) ?? _adminId;
        }
      }

      // Fetch promo codes
      final resp = await GetPromoCodesCall.call(token: currentAuthenticationToken);
      if (resp.succeeded) {
        final data = getJsonField(resp.jsonBody ?? '', r'''$.data''');
        final list = getJsonField(data, r'''$.promoCodes''');
        _promoCodes = list is List ? list : [];
      }
    } catch (e) {
      debugPrint('Promo fetch error: $e');
    }

    if (mounted) setState(() => _loadingPromos = false);
  }

  Future<void> _deactivatePromo(int promoId) async {
    if (_deactivatingIds.contains(promoId)) return;
    setState(() => _deactivatingIds.add(promoId));
    try {
      final resp = await DeactivatePromoCodeCall.call(
        token: currentAuthenticationToken,
        promoId: promoId,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promo code deactivated'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        _fetchData();
      } else {
        final msg = getJsonField(resp.jsonBody ?? '', r'''$.message''')?.toString() ?? 'Failed to deactivate';
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
      if (mounted) setState(() => _deactivatingIds.remove(promoId));
    }
  }

  Future<void> _pickExpiryDate() async {
    final initial = DateTime.tryParse(_model.expiryDateTextController!.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _model.expiryDateTextController?.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  Future<void> _createPromo() async {
    final code = _model.codeNameTextController!.text.trim().toUpperCase();
    final discountStr = _model.discountValueTextController!.text.trim();
    final maxStr = _model.maxDiscountTextController!.text.trim();
    final expiry = _model.expiryDateTextController!.text.trim();
    final usageStr = _model.usageLimitTextController!.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a code name'), backgroundColor: Colors.orange),
      );
      return;
    }

    final discountVal = double.tryParse(discountStr) ?? 0;
    if (discountVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter valid discount value'), backgroundColor: Colors.orange),
      );
      return;
    }

    final maxDiscount = double.tryParse(maxStr) ?? 0;
    final usageLimit = int.tryParse(usageStr) ?? 1000;
    final discountType = _model.selectedDiscountType ?? 'percentage';

    final resp = await AddPromoCodeCall.call(
      token: currentAuthenticationToken,
      codeName: code,
      discountType: discountType,
      discountValue: discountVal,
      maxDiscountAmount: maxDiscount,
      expiryDate: expiry.isNotEmpty ? expiry : '2025-12-31',
      usageLimit: usageLimit,
      createdByAdminId: _adminId ?? 1,
    );

    if (!mounted) return;
    if (resp.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promo code created successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      _model.codeNameTextController?.clear();
      _model.discountValueTextController?.clear();
      _model.maxDiscountTextController?.clear();
      _model.expiryDateTextController?.text = '2025-12-31';
      _model.usageLimitTextController?.text = '1000';
      setState(() {});
      _fetchData();
    } else {
      final msg = getJsonField(resp.jsonBody ?? '', r'''$.message''')?.toString() ?? 'Failed to create promo code';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
      );
    }
  }

  static List<Color> _cardGradients = [
    Color(0xFFFF6B35),
    Color(0xFFFF8F65),
    Color(0xFFE85D04),
    Color(0xFF249689),
  ];

  Widget _buildPromoCard(dynamic item, int index) {
    final id = castToType<int>(getJsonField(item, r'''$.id'''));
    final codeName = getJsonField(item, r'''$.code_name''')?.toString() ?? '—';
    final discountType = getJsonField(item, r'''$.discount_type''')?.toString() ?? 'percentage';
    final discountValue = getJsonField(item, r'''$.discount_value''')?.toString() ?? '0';
    final maxDiscount = getJsonField(item, r'''$.max_discount_amount''')?.toString();
    final usage = getJsonField(item, r'''$.current_usage_count''');
    final expiry = getJsonField(item, r'''$.expiry_date''')?.toString() ?? '';
    final status = getJsonField(item, r'''$.promo_status''')?.toString() ?? 'active';

    final gradient = _cardGradients[index % _cardGradients.length];
    final isActive = (status == 'active');
    final isDeactivating = id != null && _deactivatingIds.contains(id);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradient, gradient.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  codeName,
                  style: GoogleFonts.interTight(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    discountType == 'percentage' ? '$discountValue%' : '₹$discountValue',
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (maxDiscount != null && maxDiscount != 'null' && double.tryParse(maxDiscount) != null && double.parse(maxDiscount) > 0)
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Max discount: ₹${maxDiscount}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Used: ${castToType<int>(usage) ?? 0}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                Text(
                  'Exp: $expiry',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isActive && id != null) ...[
                      SizedBox(width: 8),
                      InkWell(
                        onTap: isDeactivating ? null : () => _deactivatePromo(id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isDeactivating
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.block, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Deactivate',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 320.ms, delay: (index * 60).ms)
        .slideX(begin: 0.05, end: 0, duration: 320.ms, delay: (index * 60).ms, curve: Curves.easeOutCubic);
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
        if (!didPop) {
          context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: true,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30.0),
              onPressed: () async {
                context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
              },
            ),
            title: Text(
              'Promo Codes',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
            ),
            centerTitle: true,
            elevation: 2.0,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: ResponsiveContainer(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create promo section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: FlutterFlowTheme.of(context).primary.withOpacity(0.12),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add_circle_outline, color: FlutterFlowTheme.of(context).primary, size: 28),
                              SizedBox(width: 10),
                              Text(
                                'Create New Promo Code',
                                style: FlutterFlowTheme.of(context).headlineSmall.override(
                                      font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                      color: FlutterFlowTheme.of(context).primaryText,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          TextFormField(
                            controller: _model.codeNameTextController,
                            focusNode: _model.codeNameFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Code Name',
                              hintText: 'e.g. NEWUSER50',
                              prefixIcon: Icon(Icons.local_offer_outlined),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (_) => setState(() {}),
                          ),
                          SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _model.selectedDiscountType ?? 'percentage',
                            decoration: InputDecoration(
                              labelText: 'Discount Type',
                              prefixIcon: Icon(Icons.percent),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: [
                              DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                              DropdownMenuItem(value: 'fixed', child: Text('Fixed (₹)')),
                            ],
                            onChanged: (v) {
                              setState(() => _model.selectedDiscountType = v ?? 'percentage');
                            },
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _model.discountValueTextController,
                            focusNode: _model.discountValueFocusNode,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: _model.selectedDiscountType == 'percentage'
                                  ? 'Discount Value (%)'
                                  : 'Discount Value (₹)',
                              hintText: _model.selectedDiscountType == 'percentage' ? '50' : '100',
                              prefixIcon: Icon(Icons.discount),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _model.maxDiscountTextController,
                            focusNode: _model.maxDiscountFocusNode,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Max Discount Amount (₹)',
                              hintText: '150',
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _model.expiryDateTextController,
                            focusNode: _model.expiryDateFocusNode,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Expiry Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onTap: _pickExpiryDate,
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _model.usageLimitTextController,
                            focusNode: _model.usageLimitFocusNode,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Usage Limit',
                              hintText: '1000',
                              prefixIcon: Icon(Icons.people_outline),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          SizedBox(height: 24),

                          FFButtonWidget(
                            onPressed: _createPromo,
                            text: 'Create Promo Code',
                            icon: Icon(Icons.add, color: Colors.white, size: 22),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 52,
                              color: const Color(0xFFFF6B35),
                              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                  ),
                              elevation: 2,
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28),

                    // Promo list section
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: FlutterFlowTheme.of(context).primary, size: 26),
                        SizedBox(width: 10),
                        Text(
                          'Active Promo Codes',
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    if (_loadingPromos)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary),
                        ),
                      )
                    else if (_promoCodes.isEmpty)
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey.shade400),
                              SizedBox(height: 16),
                              Text(
                                'No promo codes yet',
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                              ),
                              Text(
                                'Create your first promo above',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: List.generate(_promoCodes.length, (i) => _buildPromoCard(_promoCodes[i], i)),
                      ),
                  ],
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
