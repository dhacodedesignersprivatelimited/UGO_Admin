import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/finance_repository.dart';

enum PayoutFilter { pendingManual, all, pending, completed, failed }

class PayoutsState {
  final List<Map<String, dynamic>> payouts;
  final PayoutFilter filter;

  PayoutsState({required this.payouts, required this.filter});

  PayoutsState copyWith({List<Map<String, dynamic>>? payouts, PayoutFilter? filter}) {
    return PayoutsState(
      payouts: payouts ?? this.payouts,
      filter: filter ?? this.filter,
    );
  }
}

class PayoutsNotifier extends AutoDisposeAsyncNotifier<PayoutsState> {
  PayoutFilter _currentFilter = PayoutFilter.pendingManual;

  @override
  FutureOr<PayoutsState> build() async {
    return _fetchPayouts();
  }

  Future<PayoutsState> _fetchPayouts() async {
    final repository = ref.read(financeRepositoryProvider);
    final status = _mapFilterToStatus(_currentFilter);
    final payouts = await repository.getDriverPayouts(status);
    return PayoutsState(payouts: payouts, filter: _currentFilter);
  }

  String? _mapFilterToStatus(PayoutFilter filter) {
    switch (filter) {
      case PayoutFilter.pendingManual:
        return 'pending_manual_transfer';
      case PayoutFilter.pending:
        return 'pending';
      case PayoutFilter.completed:
        return 'completed';
      case PayoutFilter.failed:
        return 'failed';
      case PayoutFilter.all:
        return null;
    }
  }

  Future<void> setFilter(PayoutFilter filter) async {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPayouts());
  }

  Future<void> markPaid(int payoutId, String? paymentReference) async {
    final repository = ref.read(financeRepositoryProvider);
    await repository.processPayout(payoutId, paymentReference);
    // Refresh after mutation
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPayouts());
  }

  Future<void> reject(int payoutId, String reason) async {
    final repository = ref.read(financeRepositoryProvider);
    await repository.rejectPayout(payoutId, reason);
    // Refresh after mutation
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPayouts());
  }

  Future<void> hold(int payoutId, String reason) async {
    final repository = ref.read(financeRepositoryProvider);
    await repository.holdPayout(payoutId, reason);
    // Refresh after mutation
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPayouts());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPayouts());
  }
}

final payoutsProvider = AsyncNotifierProvider.autoDispose<PayoutsNotifier, PayoutsState>(() {
  return PayoutsNotifier();
});
