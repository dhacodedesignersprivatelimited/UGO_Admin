import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/components/admin_pop_scope.dart';
import '/components/responsive_body.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
    final fcmToken = _model.fcmTokenTextController!.text.trim();

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
        fcmToken: fcmToken.isEmpty ? 'admin_created' : fcmToken,
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
        final msg = getJsonField(response.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to create user';
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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            onPressed: () =>
                context.goNamedAuth(AllusersWidget.routeName, context.mounted),
          ),
          title: Text(
            'Create User',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: ResponsiveContainer(
            maxWidth: 600,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _model.mobileNumberTextController!,
                focusNode: _model.mobileNumberFocusNode!,
                label: 'Mobile Number',
                hint: 'e.g. 9985956313',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _model.firstNameTextController!,
                focusNode: _model.firstNameFocusNode!,
                label: 'First Name',
                hint: 'e.g. Pavan',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _model.lastNameTextController!,
                focusNode: _model.lastNameFocusNode!,
                label: 'Last Name',
                hint: 'e.g. Kumar',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _model.emailTextController!,
                focusNode: _model.emailFocusNode!,
                label: 'Email',
                hint: 'e.g. user@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _model.fcmTokenTextController!,
                focusNode: _model.fcmTokenFocusNode!,
                label: 'FCM Token (optional)',
                hint: 'Leave empty if unknown',
                prefixIcon: Icons.token_rounded,
              ),
              const SizedBox(height: 32),
              FFButtonWidget(
                onPressed: _isSubmitting ? null : () => _submit(),
                text: _isSubmitting ? 'Creating...' : 'Create User',
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_rounded, size: 22, color: Colors.white),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 52,
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: Colors.white,
                      ),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                  ),
              ),
            ],
          ),
        ),
        ),
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
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: FlutterFlowTheme.of(context).primary),
        filled: true,
        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
            width: 2,
          ),
        ),
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(),
          ),
    );
  }
}
