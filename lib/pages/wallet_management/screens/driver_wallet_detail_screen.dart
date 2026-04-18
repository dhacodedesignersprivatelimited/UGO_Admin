import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_scaffold.dart';
import 'driver_wallet_transactions_screen.dart';
import '../widgets/driver_wallet_card.dart';

class DriverWalletDetailScreen extends StatefulWidget {
  const DriverWalletDetailScreen({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.phone,
    required this.balance,
    required this.totalRides,
    required this.totalEarnings,
    this.avatarUrl,
  });

  final int driverId;
  final String driverName;
  final String phone;
  final String balance;
  final int totalRides;
  final String totalEarnings;
  final String? avatarUrl;

  @override
  State<DriverWalletDetailScreen> createState() => _DriverWalletDetailScreenState();
}

class _DriverWalletDetailScreenState extends State<DriverWalletDetailScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final resp = await GetDriverWalletTransactionsCall.call(
        driverId: widget.driverId,
        token: token,
        page: 1,
        pageSize: 20,
      );
      if (!resp.succeeded) {
        setState(() => _loading = false);
        return;
      }
      final rows = GetDriverWalletTransactionsCall.transactionsList(resp.jsonBody)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map((row) {
        final t = (row['type']?.toString() ?? '').toLowerCase();
        final isCredit = t.contains('credit') || t.contains('recharge') || t.contains('bonus');
        final rawDate = row['date']?.toString() ?? row['created_at']?.toString() ?? '';
        final parsed = DateTime.tryParse(rawDate);
        final prettyTime = parsed == null
            ? rawDate
            : DateFormat('dd MMM, hh:mm a').format(parsed.toLocal());
        return <String, dynamic>{
          'type': isCredit ? 'credit' : 'debit',
          'amount': row['amount']?.toString() ?? '0',
          'title': row['description']?.toString() ?? 'Wallet transaction',
          'time': prettyTime,
        };
      }).toList();
      if (!mounted) return;
      setState(() {
        _activities = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Driver Wallet',
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            ),
          DriverWalletCard(
            driverName: widget.driverName,
            phone: widget.phone,
            balance: widget.balance,
            totalRides: widget.totalRides,
            totalEarnings: widget.totalEarnings,
            avatarUrl: widget.avatarUrl,
            activities: _activities,
            onAddMoney: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DriverWalletTransactionsScreen(
                    driverId: widget.driverId,
                    driverName: widget.driverName,
                    showCredits: true,
                  ),
                ),
              );
            },
            onDeductMoney: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DriverWalletTransactionsScreen(
                    driverId: widget.driverId,
                    driverName: widget.driverName,
                    showCredits: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
