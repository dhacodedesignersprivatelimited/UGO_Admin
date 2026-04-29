import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';

class FinanceRepository {
  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = currentAuthenticationToken;
    // Use the working /admins/dashboard endpoint
    final response = await DashBoardCall.call(token: token);
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to load dashboard stats'));
    }
    final data = Map<String, dynamic>.from(
        (DashBoardCall.data(response.jsonBody) as Map<String, dynamic>?) ?? {});

    // Also fetch recent wallet transactions for the earnings trend chart
    try {
      final txRes = await GetAdminWalletTransactionsCall.call(
        token: token,
        page: 1,
        limit: 100,
      );
      if (txRes.succeeded) {
        final txList = GetAdminWalletTransactionsCall.transactionsList(txRes.jsonBody);
        data['recent_transactions'] = txList;
      }
    } catch (_) {
      // chart data is optional — ignore failure
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getRides() async {
    final token = currentAuthenticationToken;
    final response = await GetRidesCall.call(token: token);
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to load rides'));
    }
    final rawList = GetRidesCall.data(response.jsonBody) ?? [];
    return rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPayments() async {
    final token = currentAuthenticationToken;
    final response = await GetPaymentsCall.call(token: token);
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to load payments'));
    }
    final rawList = GetPaymentsCall.paymentsList(response.jsonBody);
    return rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getDriverPayouts(String? status) async {
    final token = currentAuthenticationToken;
    final response = await GetAdminUnifiedPayoutsCall.call(
      token: token,
      page: 1,
      limit: 100, // Pulling a larger limit to match UI
      status: status ?? 'all',
    );
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to load driver payouts'));
    }
    final rawList = GetAdminUnifiedPayoutsCall.payoutsList(response.jsonBody);
    return rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> processPayout(int payoutId, String? paymentReference) async {
    final token = currentAuthenticationToken;
    final response = await MarkPayoutPaidCall.call(
      token: token,
      payoutId: payoutId,
      paymentReference: paymentReference,
    );
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to process payout'));
    }
  }

  Future<void> rejectPayout(int payoutId, String reason) async {
    final token = currentAuthenticationToken;
    final response = await PostAdminPayoutRejectCall.call(
      token: token,
      payoutId: payoutId,
      reason: reason,
    );
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to reject payout'));
    }
  }

  Future<void> holdPayout(int payoutId, String reason) async {
    final token = currentAuthenticationToken;
    final response = await PostAdminFinanceWorkflowPayoutHoldCall.call(
      token: token,
      payoutId: payoutId,
      reason: reason,
    );
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to hold payout'));
    }
  }

  Future<dynamic> getReports(String kind, {String? from, String? to, String? group}) async {
    final token = currentAuthenticationToken;

    // Fetch live data from working endpoints
    final dashRes = await DashBoardCall.call(token: token);
    final dashData = dashRes.succeeded
        ? (DashBoardCall.data(dashRes.jsonBody) as Map<String, dynamic>? ?? {})
        : <String, dynamic>{};

    final txRes = await GetAdminWalletTransactionsCall.call(
      token: token,
      page: 1,
      limit: 100,
    );
    final txList = txRes.succeeded
        ? GetAdminWalletTransactionsCall.transactionsList(txRes.jsonBody)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    final walletsRes = await GetWalletsCall.call(token: token);
    final allWallets = walletsRes.succeeded
        ? (GetWalletsCall.walletsList(walletsRes.jsonBody) ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    // Apply date filter
    bool _inRange(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return true;
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return true;
      final d = dt.toLocal();
      if (from != null) {
        final f = DateTime.tryParse(from!);
        if (f != null && d.isBefore(f)) return false;
      }
      if (to != null) {
        final t = DateTime.tryParse(to!);
        if (t != null && d.isAfter(t.add(const Duration(days: 1)))) return false;
      }
      return true;
    }

    final filteredTxns = txList.where((t) => _inRange(t['date']?.toString())).toList();

    if (kind == 'revenue') {
      // Build revenue report from dashboard + transactions
      double totalCredit = 0, totalDebit = 0;
      final byDate = <String, double>{};

      for (final t in filteredTxns) {
        final type = (t['type']?.toString() ?? '').toLowerCase();
        final amount = _toDouble(t['amount']);
        final dateKey = _safeDateKey(t['date']);

        if (type.contains('credit') || type.contains('recharge') || type.contains('bonus')) {
          totalCredit += amount;
        } else {
          totalDebit += amount;
        }

        if (dateKey.isNotEmpty) {
          byDate[dateKey] = (byDate[dateKey] ?? 0) + amount;
        }
      }

      final totalEarnings = _toDouble(dashData['total_earnings']);
      final adminBalance = _toDouble(dashData['admin_wallet_balance']);

      // Build time series
      final sortedKeys = byDate.keys.toList()..sort();
      final series = sortedKeys.map((k) => {
        'period_key': k,
        'net_platform_movement_inr': byDate[k],
        'earnings_inr': byDate[k],
      }).toList();

      return {
        'data': {
          'kind': 'revenue',
          'ledger': {
            'net_platform_movement_inr': totalEarnings,
            'total_commission_ledger_inr': adminBalance,
            'total_referral_pool_in_inr': totalCredit,
            'total_referral_match_payout_inr': totalDebit,
            'by_type': {
              'credit': totalCredit,
              'debit': totalDebit,
              'total_earnings': totalEarnings,
            },
          },
          'revenue_time_series': {
            'series': series,
          },
          'total_rides': dashData['total_rides'],
        }
      };
    }

    if (kind == 'payouts') {
      // Group transactions by type as payout status breakdown
      final byType = <String, Map<String, dynamic>>{};
      for (final t in filteredTxns) {
        final type = (t['type']?.toString() ?? 'Unknown');
        final amount = _toDouble(t['amount']);
        if (!byType.containsKey(type)) {
          byType[type] = {'status': type, 'cnt': 0, 'amt': 0.0};
        }
        byType[type]!['cnt'] = (byType[type]!['cnt'] as int) + 1;
        byType[type]!['amt'] = (byType[type]!['amt'] as double) + amount;
      }

      return {
        'data': {
          'kind': 'payouts',
          'by_status': byType.values.toList(),
          'total_transactions': filteredTxns.length,
        }
      };
    }

    if (kind == 'referrals') {
      // Build wallet summary as referral-like report
      final userWallets = allWallets.where((w) => w['user_id'] != null).toList();
      final driverWallets = allWallets.where((w) => w['driver_id'] != null).toList();

      double userTotal = 0, driverTotal = 0;
      for (final w in userWallets) userTotal += _toDouble(w['wallet_balance']);
      for (final w in driverWallets) driverTotal += _toDouble(w['wallet_balance']);

      final rows = driverWallets.where((w) => _toDouble(w['wallet_balance']) != 0).take(20).map((w) => {
        'driver_referral_id': w['driver_id'],
        'period_key': _safeDateKey(w['last_transaction_date'], fallback: 'N/A'),
        'matched_pro_rides': 0,
        'theoretical_max_payout_inr': _toDouble(w['total_earned_coins']),
        'accrued_referrer_payout_inr': _toDouble(w['wallet_balance']),
      }).toList();

      return {
        'data': {
          'kind': 'referrals',
          'rate_inr_per_match': 0,
          'wallet_summary': {
            'user_wallets': userWallets.length,
            'driver_wallets': driverWallets.length,
            'user_total_balance': userTotal,
            'driver_total_balance': driverTotal,
          },
          'rows': rows,
        }
      };
    }

    throw Exception('Unknown report kind: $kind');
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _safeDateKey(dynamic raw, {String fallback = ''}) {
    final s = raw?.toString().trim() ?? '';
    if (s.isEmpty) return fallback;
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  String _getErrorMessage(dynamic body, String defaultMsg) {
    if (body is Map) {
      return body['message']?.toString() ?? defaultMsg;
    }
    return defaultMsg;
  }
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository();
});
