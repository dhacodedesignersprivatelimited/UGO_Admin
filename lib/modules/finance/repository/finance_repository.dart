import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';

class FinanceRepository {
  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = currentAuthenticationToken;
    final response = await GetAdminFinanceSummaryCall.call(token: token);
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to load dashboard stats'));
    }
    return GetAdminFinanceSummaryCall.data(response.jsonBody) ?? {};
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
    final response = await GetAdminFinanceReportCall.call(
      token: token,
      kind: kind,
      from: from,
      to: to,
      group: group,
    );
    if (!response.succeeded) {
      throw Exception(_getErrorMessage(response.jsonBody, 'Failed to load report'));
    }
    return response.jsonBody;
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
