import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/responsive_body.dart';
import '/index.dart';
import '/config/theme/flutter_flow_choice_chips.dart';
import '/config/theme/flutter_flow_icon_button.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import '/config/theme/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_model.dart';
export 'notifications_model.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  late NotificationsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSending = false;

  static const _historyGradients = [
    Color(0xFFFF6B35),
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsModel());

    _model.titleTextController ??= TextEditingController();
    _model.titleFocusNode ??= FocusNode();

    _model.messageTextController ??= TextEditingController();
    _model.messageFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _targetFromChip(String? chip) {
    if (chip == null) return 'all_users';
    if (chip == 'Drivers') return 'all_drivers';
    return 'all_users';
  }

  Future<void> _sendNotification() async {
    final title = _model.titleTextController?.text.trim() ?? '';
    final message = _model.messageTextController?.text.trim() ?? '';

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title')),
      );
      return;
    }
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a message')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final target = _targetFromChip(_model.choiceChipsValue);
      final priority = _model.selectedPriority ?? 'high';
      final response = await SendNotificationCall.call(
        token: currentAuthenticationToken,
        title: title,
        message: message,
        target: target,
        priority: priority,
      );
      if (!mounted) return;
      if (response.succeeded) {
        final data = getJsonField(response.jsonBody ?? '', r'''$.data''');
        final recipients = castToType<int>(getJsonField(data, r'''$.recipients'''));
        final msg = recipients != null
            ? 'Notification sent to $recipients recipients'
            : 'Notification sent successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        _model.titleTextController?.clear();
        _model.messageTextController?.clear();
        setState(() {});
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to send notification';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
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
              onPressed: () =>
                  context.goNamedAuth(DashboardScreen.routeName, context.mounted),
            ),
            title: Text(
              'Notifications',
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContainer(
                maxWidth: 800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compose card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context).primary,
                                      FlutterFlowTheme.of(context).primary.withValues(alpha:0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Compose Notification',
                                style: FlutterFlowTheme.of(context).headlineSmall.override(
                                      font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                      color: FlutterFlowTheme.of(context).primaryText,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _model.titleTextController,
                            focusNode: _model.titleFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'e.g. System Maintenance',
                              prefixIcon: Icon(Icons.title, color: FlutterFlowTheme.of(context).primary),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2),
                              ),
                            ),
                            validator: _model.titleTextControllerValidator?.asValidator(context),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _model.messageTextController,
                            focusNode: _model.messageFocusNode,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Message',
                              hintText: 'e.g. The system will be down from 2 AM to 3 AM.',
                              prefixIcon: Icon(Icons.message_outlined, color: FlutterFlowTheme.of(context).primary),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2),
                              ),
                            ),
                            validator: _model.messageTextControllerValidator?.asValidator(context),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Target Audience',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                          ),
                          const SizedBox(height: 12),
                          FlutterFlowChoiceChips(
                            options: const [
                              ChipData('All Users'),
                              ChipData('Drivers'),
                              ChipData('Users'),
                            ],
                            onChanged: (val) => safeSetState(() => _model.choiceChipsValue = val?.firstOrNull),
                            selectedChipStyle: ChipStyle(
                              backgroundColor: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                  ),
                              elevation: 2,
                              borderColor: FlutterFlowTheme.of(context).primary,
                              borderWidth: 1,
                            ),
                            unselectedChipStyle: ChipStyle(
                              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                              elevation: 0,
                              borderColor: FlutterFlowTheme.of(context).alternate,
                              borderWidth: 1,
                            ),
                            chipSpacing: 10,
                            rowSpacing: 10,
                            multiselect: false,
                            alignment: WrapAlignment.start,
                            controller: _model.choiceChipsValueController ??=
                                FormFieldController<List<String>>([]),
                            wrapped: true,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Priority',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _model.selectedPriority ?? 'high',
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.priority_high, color: FlutterFlowTheme.of(context).primary),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'high', child: Text('High')),
                              DropdownMenuItem(value: 'normal', child: Text('Normal')),
                            ],
                            onChanged: (v) {
                              setState(() => _model.selectedPriority = v ?? 'high');
                            },
                          ),
                          const SizedBox(height: 24),
                          FFButtonWidget(
                            onPressed: _isSending ? null : _sendNotification,
                            text: _isSending ? 'Sending...' : 'Send Notification',
                            icon: _isSending
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
                    )
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 28),
                    // History section
                    Row(
                      children: [
                        Icon(Icons.history, color: FlutterFlowTheme.of(context).primary, size: 26),
                        const SizedBox(width: 10),
                        Text(
                          'Recent Notifications',
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 60.ms)
                        .slideX(begin: -0.02, end: 0, delay: 60.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    _buildHistoryCard('New Features Available', 'Sent to All', '2d ago', 0)
                        .animate()
                        .fadeIn(duration: 320.ms, delay: 100.ms)
                        .slideX(begin: 0.04, end: 0, delay: 100.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 12),
                    _buildHistoryCard('Driver Bonus Program', 'Sent to Drivers', '1w ago', 1)
                        .animate()
                        .fadeIn(duration: 320.ms, delay: 180.ms)
                        .slideX(begin: 0.04, end: 0, delay: 180.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 12),
                    _buildHistoryCard('Ride Discounts This Weekend', 'Sent to Users', '2w ago', 2)
                        .animate()
                        .fadeIn(duration: 320.ms, delay: 260.ms)
                        .slideX(begin: 0.04, end: 0, delay: 260.ms, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String title, String subtitle, String time, int index) {
    final gradient = _historyGradients[index % _historyGradients.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradient, gradient.withValues(alpha:0.85)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.withValues(alpha:0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha:0.9),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha:0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
