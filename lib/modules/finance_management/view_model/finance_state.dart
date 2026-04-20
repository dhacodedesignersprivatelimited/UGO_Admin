import 'package:equatable/equatable.dart';

import '/core/utils/view_state.dart';
import '/modules/finance_management/model/finance_model.dart';

class FinanceState extends Equatable with LoadStateMixin {
  const FinanceState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.withdrawals = const [],
    this.ledger = const [],
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<WithdrawalRequest> withdrawals;
  final List<WalletLedgerEntry> ledger;

  List<WithdrawalRequest> get pendingWithdrawals => withdrawals
      .where((w) =>
          (w.status.name.toLowerCase()).contains('pending'))
      .toList();

  FinanceState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<WithdrawalRequest>? withdrawals,
    List<WalletLedgerEntry>? ledger,
  }) =>
      FinanceState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        withdrawals: withdrawals ?? this.withdrawals,
        ledger: ledger ?? this.ledger,
      );

  @override
  List<Object?> get props => [status, errorMessage, withdrawals, ledger];
}
