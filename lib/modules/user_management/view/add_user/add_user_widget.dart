import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/responsive_body.dart';
import '/index.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_user_model.dart';
export 'add_user_model.dart';

class AddUserWidget extends StatefulWidget {
  const AddUserWidget({super.key});

  static String routeName = 'AddUser';
  static String routePath = '/add-user';

  @override
  State<AddUserWidget> createState() => _AddUserWidgetState();
}

class _AddUserWidgetState extends State<AddUserWidget> {
  late AddUserModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddUserModel());
    _model.mobileNumberTextController ??= TextEditingController();
    _model.mobileNumberFocusNode ??= FocusNode();
    _model.firstNameTextController ??= TextEditingController();
    _model.firstNameFocusNode ??= FocusNode();
    _model.lastNameTextController ??= TextEditingController();
    _model.lastNameFocusNode ??= FocusNode();
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    // Controllers for FCM initialized in model to prevent null errors, but ignored in UI
    _model.fcmTokenTextController ??= TextEditingController();
    _model.fcmTokenFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final mobile = _model.mobileNumberTextController!.text.trim();
    final firstName = _model.firstNameTextController!.text.trim();
    final lastName = _model.lastNameTextController!.text.trim();
    final email = _model.emailTextController!.text.trim();

    if (mobile.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill mobile, first name, last name, and email')),
      );
      return;
    }

    safeSetState(() => _isSubmitting = true);
    try {
      final response = await CreateUserCall.call(
        token: currentAuthenticationToken,
        mobileNumber: mobile,
        firstName: firstName,
        lastName: lastName,
        email: email,
        fcmToken: 'admin_created', // Hardcoded safely behind the scenes
      );

      if (!mounted) return;
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        context.goNamedAuth(AllusersWidget.routeName, context.mounted);
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')?.toString() ?? 'Failed to create user';
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
      if (mounted) safeSetState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      fallbackRouteName: AllusersWidget.routeName,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: () => context.goNamedAuth(AllusersWidget.routeName, context.mounted),
            ),
            title: Text(
              'New User',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: ResponsiveContainer(
                    maxWidth: 700,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionCard(
                          title: 'Personal Information',
                          icon: Icons.person_rounded,
                          children: [
                            _buildTextField(
                              controller: _model.mobileNumberTextController!,
                              focusNode: _model.mobileNumberFocusNode!,
                              label: 'Mobile Number *',
                              hint: 'e.g. 9985956313',
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_rounded,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _model.firstNameTextController!,
                                    focusNode: _model.firstNameFocusNode!,
                                    label: 'First Name *',
                                    hint: 'e.g. Pavan',
                                    prefixIcon: Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _model.lastNameTextController!,
                                    focusNode: _model.lastNameFocusNode!,
                                    label: 'Last Name *',
                                    hint: 'e.g. Kumar',
                                    prefixIcon: Icons.person_outline_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _model.emailTextController!,
                              focusNode: _model.emailFocusNode!,
                              label: 'Email Address *',
                              hint: 'e.g. user@example.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40), // Spacer before bottom bar
                      ],
                    ),
                  ),
                ),
              ),

              // Sticky Bottom Action Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: FFButtonWidget(
                      onPressed: _isSubmitting ? null : () => _submit(),
                      text: _isSubmitting ? 'Creating User Profile...' : 'Complete User Onboarding',
                      icon: _isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                        elevation: 3,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    required IconData prefixIcon,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.bodyMedium.override(
          font: GoogleFonts.inter(),
          color: theme.secondaryText,
        ),
        hintText: hint,
        hintStyle: theme.bodySmall.override(
          font: GoogleFonts.inter(),
          color: theme.alternate,
        ),
        prefixIcon: Icon(prefixIcon, color: theme.secondaryText, size: 20),
        filled: true,
        fillColor: theme.primaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.alternate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primary,
            width: 2,
          ),
        ),
      ),
      style: theme.bodyMedium.override(
        font: GoogleFonts.inter(),
      ),
    );
  }
}