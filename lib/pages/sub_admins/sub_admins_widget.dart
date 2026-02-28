import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/admin_scaffold.dart';
import 'sub_admins_model.dart';
export 'sub_admins_model.dart';

class SubAdminsWidget extends StatefulWidget {
  const SubAdminsWidget({super.key});

  static String routeName = 'SubAdmins';
  static String routePath = '/sub-admins';

  @override
  State<SubAdminsWidget> createState() => _SubAdminsWidgetState();
}

class _SubAdminsWidgetState extends State<SubAdminsWidget> {
  late SubAdminsModel _model;
  late Future<ApiCallResponse> _adminsFuture;

  static const List<String> _roles = [
    'SUPER_ADMIN',
    'MANAGER',
    'CITY_ADMIN',
    'SUPPORT',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubAdminsModel());
    _model.adminNameTextController ??= TextEditingController();
    _model.adminNameFocusNode ??= FocusNode();
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
    _model.selectedRole ??= 'MANAGER';
    _adminsFuture = GetAllAdminsCall.call(token: currentAuthenticationToken);
  }

  void _refreshAdmins() {
    setState(() {
      _adminsFuture =
          GetAllAdminsCall.call(token: currentAuthenticationToken);
    });
  }

  void _showAddAdminDialog() {
    _model.adminNameTextController?.clear();
    _model.emailTextController?.clear();
    _model.passwordTextController?.clear();
    _model.selectedRole = 'MANAGER';
    showDialog(
      context: context,
      builder: (context) => _AddAdminDialog(
        model: _model,
        roles: _roles,
        onSuccess: () {
          Navigator.pop(context);
          _refreshAdmins();
        },
        onCancel: () => Navigator.pop(context),
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
    final theme = FlutterFlowTheme.of(context);

    return AdminScaffold(
      title: 'Sub-Admins & Roles',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OutlinedButton.icon(
            onPressed: _showAddAdminDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Sub-Admin'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primary,
              side: BorderSide(color: theme.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 20),
          Text('Roles', style: theme.titleMedium.override(font: GoogleFonts.inter())),
          const SizedBox(height: 12),
          _roleCard('Super Admin', 'Full access', theme),
          _roleCard('Manager', 'Manage operations', theme),
          _roleCard('City Admin', 'City-level access', theme),
          _roleCard('Support', 'View & support only', theme),
          const SizedBox(height: 20),
          Text('Sub-Admins', style: theme.titleMedium.override(font: GoogleFonts.inter())),
          const SizedBox(height: 12),
          FutureBuilder<ApiCallResponse>(
            future: _adminsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: theme.primary),
                  ),
                );
              }
              final response = snapshot.data!;
              List<dynamic> admins = [];
              if (response.succeeded) {
                final data = getJsonField(response.jsonBody, r'''$.data''');
                if (data is List) admins = data;
              }
              if (admins.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No admins yet. Tap "Add Sub-Admin" to create one.',
                    style: theme.bodyMedium.override(color: theme.secondaryText),
                  ),
                );
              }
              return Column(
                children: admins
                    .map<Widget>((a) {
                      final email = getJsonField(a, r'''$.email''')?.toString() ?? '';
                      final name = getJsonField(a, r'''$.adminName''')?.toString() ?? '';
                      final role = getJsonField(a, r'''$.role''')?.toString() ?? '—';
                      final display = email.isNotEmpty ? email : (name.isNotEmpty ? name : '—');
                      return _adminCard(display, role, theme);
                    })
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _roleCard(String name, String desc, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primary.withValues(alpha:0.2),
            child: Icon(Icons.admin_panel_settings, color: theme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.titleSmall.override(font: GoogleFonts.inter())),
                Text(desc, style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.secondaryText)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.edit, color: theme.primary, size: 20)),
        ],
      ),
    );
  }

  Widget _adminCard(String email, String role, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primary.withValues(alpha:0.2),
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : '?',
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email, style: theme.titleSmall.override(font: GoogleFonts.inter())),
                Text(role, style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.secondaryText)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: theme.primary)),
        ],
      ),
    );
  }
}

class _AddAdminDialog extends StatefulWidget {
  const _AddAdminDialog({
    required this.model,
    required this.roles,
    required this.onSuccess,
    required this.onCancel,
  });

  final SubAdminsModel model;
  final List<String> roles;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  @override
  State<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<_AddAdminDialog> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final name = widget.model.adminNameTextController?.text.trim() ?? '';
    final email = widget.model.emailTextController?.text.trim() ?? '';
    final password = widget.model.passwordTextController?.text ?? '';
    final role = widget.model.selectedRole ?? 'MANAGER';

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name, email and password')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await CreateAdminCall.call(
        token: currentAuthenticationToken,
        adminName: name,
        email: email,
        password: password,
        role: role,
      );

      if (!mounted) return;
      if (response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin created successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        widget.onSuccess();
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to create admin';
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AlertDialog(
      title: Text('Create Admin', style: theme.titleLarge.override(font: GoogleFonts.inter())),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget.model.adminNameTextController,
              focusNode: widget.model.adminNameFocusNode,
              decoration: InputDecoration(
                labelText: 'Admin Name *',
                hintText: 'e.g. sony',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.model.emailTextController,
              focusNode: widget.model.emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'e.g. sony14@gmail.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.model.passwordTextController,
              focusNode: widget.model.passwordFocusNode,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'e.g. Admin@123',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.model.selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: widget.roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => widget.model.selectedRole = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: theme.primary),
          child: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
