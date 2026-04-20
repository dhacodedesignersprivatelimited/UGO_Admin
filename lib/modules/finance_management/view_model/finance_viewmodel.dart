import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/shared/models/domain_enums.dart';
import '/modules/finance_management/repository/finance_admin_repository.dart';
import '/shared/providers/app_providers.dart';
import '/core/utils/view_state.dart';
import 'finance_state.dart';

export 'finance_state.dart';

/// ViewModel for the finance / payouts hub screen.
class FinanceViewModel extends StateNotifier<FinanceState> {
  FinanceViewModel(this._repo) : super(const FinanceState());

  final FinanceAdminRepository _repo;

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final withdrawals = await _repo.withdrawals();
      state = state.copyWith(
          status: LoadStatus.success, withdrawals: withdrawals);
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  Future<void> approveWithdrawal(String id) async {
    await _repo.decideWithdrawal(id: id, decision: WithdrawalStatus.approved);
    await refresh();
  }

  Future<void> rejectWithdrawal(String id, {String? note}) async {
    await _repo.decideWithdrawal(id: id, decision: WithdrawalStatus.rejected);
    await refresh();
  }
}

final _financeRepoProvider = Provider<FinanceAdminRepository>((ref) {
  return ref.watch(adminDepsProvider).finance;
});

/// Global finance ViewModel provider.
final financeViewModelProvider =
    StateNotifierProvider<FinanceViewModel, FinanceState>((ref) {
  return FinanceViewModel(ref.watch(_financeRepoProvider));
});
