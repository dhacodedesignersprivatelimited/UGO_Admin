import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/admin_scaffold.dart';
import 'driver_payouts_model.dart';
export 'driver_payouts_model.dart';

class DriverPayoutsWidget extends StatefulWidget {
  const DriverPayoutsWidget({super.key});

  static String routeName = 'DriverPayouts';
  static String routePath = '/driver-payouts';

  @override
  State<DriverPayoutsWidget> createState() => _DriverPayoutsWidgetState();
}

class _DriverPayoutsWidgetState extends State<DriverPayoutsWidget> {
  late DriverPayoutsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverPayoutsModel());
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
      title: 'Driver Payouts',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pending', style: theme.labelMedium.override(font: GoogleFonts.inter())),
                    Text('₹24,500', style: theme.headlineSmall.override(font: GoogleFonts.interTight(), color: theme.primary)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primary, foregroundColor: Colors.white),
                  child: const Text('Export'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Weekly Payouts', style: theme.titleMedium.override(font: GoogleFonts.inter())),
          const SizedBox(height: 12),
          ...List.generate(5, (i) => _payoutItem(i, theme)),
        ],
      ),
    );
  }

  Widget _payoutItem(int i, FlutterFlowTheme theme) {
    const names = ['Raj Kumar', 'Amit Singh', 'Vikram Patel', 'Suresh Nair', 'Deepak Sharma'];
    const amounts = [4500, 3200, 5100, 2800, 5900];
    const statuses = ['pending', 'paid', 'pending', 'failed', 'paid'];

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
            backgroundColor: theme.primary.withOpacity(0.2),
            child: Text('${i + 1}', style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(names[i], style: theme.titleSmall.override(font: GoogleFonts.inter())),
                Text('Week ${5 - i}', style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.secondaryText)),
              ],
            ),
          ),
          Text('₹${amounts[i]}', style: theme.titleMedium.override(font: GoogleFonts.inter(), color: theme.primary)),
          const SizedBox(width: 12),
          Chip(
            label: Text(statuses[i], style: const TextStyle(fontSize: 11)),
            backgroundColor: _statusColor(statuses[i]).withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    if (s == 'paid') return Colors.green;
    if (s == 'pending') return Colors.orange;
    return Colors.red;
  }
}
