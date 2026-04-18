import 'package:flutter/foundation.dart';

import '../../../core/admin_staff_role.dart';
import '../../../core/loadable.dart';
import '../../../data/models/domain_enums.dart';
import '../../../data/models/finance_models.dart';
import '../../../data/repositories/finance_admin_repository.dart';

class FinanceHubViewModel extends ChangeNotifier {
  FinanceHubViewModel({
    required FinanceAdminRepository repository,
    required AdminPrincipal principal,
  })  : _repository = repository,
        _principal = principal;

  final FinanceAdminRepository _repository;
  final AdminPrincipal _principal;

  Loadable<List<WithdrawalRequest>> withdrawalsState = const Loadable();

  bool get canApprove => _principal.can(AdminPermission.approveWithdrawals);

  Future<void> refresh() async {
    withdrawalsState = withdrawalsState.copyWith(status: LoadStatus.loading);
    notifyListeners();
    try {
      final data = await _repository.withdrawals(status: WithdrawalStatus.pending);
      withdrawalsState = Loadable(status: LoadStatus.success, data: data);
    } catch (e) {
      withdrawalsState = Loadable(status: LoadStatus.failure, message: e.toString());
    }
    notifyListeners();
  }

  Future<void> approve(String id) async {
    if (!canApprove) return;
    await _repository.decideWithdrawal(id: id, decision: WithdrawalStatus.approved);
    await refresh();
  }

  Future<void> reject(String id) async {
    if (!canApprove) return;
    await _repository.decideWithdrawal(id: id, decision: WithdrawalStatus.rejected);
    await refresh();
  }
}
