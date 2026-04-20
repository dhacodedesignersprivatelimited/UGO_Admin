import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/utils/view_state.dart';
import 'wallet_state.dart';

export 'wallet_state.dart';

/// ViewModel for the admin wallet / company balance screen.
class WalletViewModel extends StateNotifier<WalletState> {
  WalletViewModel() : super(const WalletState());

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final token = currentAuthenticationToken ?? '';
      final res = await CompanyWalletCall.call(token: token);
      final balance = _extractBalance(res.jsonBody);
      state = state.copyWith(
          status: LoadStatus.success, balance: balance ?? state.balance);
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  static double? _extractBalance(dynamic body) {
    if (body is! Map) return null;
    final data = body['data'] ?? body;
    for (final key in ['total', 'balance', 'company_balance']) {
      final v = (data is Map) ? data[key] : null;
      if (v is num) return v.toDouble();
    }
    return null;
  }
}

/// Global wallet ViewModel provider.
final walletViewModelProvider =
    StateNotifierProvider<WalletViewModel, WalletState>(
  (_) => WalletViewModel(),
);
