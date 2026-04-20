import 'package:equatable/equatable.dart';
import '/core/utils/view_state.dart';

class WalletState extends Equatable with LoadStateMixin {
  const WalletState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.transactions = const [],
    this.balance = 0,
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<dynamic> transactions;
  final double balance;

  WalletState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<dynamic>? transactions,
    double? balance,
  }) =>
      WalletState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        transactions: transactions ?? this.transactions,
        balance: balance ?? this.balance,
      );

  @override
  List<Object?> get props => [status, errorMessage, transactions, balance];
}
