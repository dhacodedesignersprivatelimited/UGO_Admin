import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/finance_repository.dart';

class ReportsState {
  final dynamic data;
  final String? reportKind;

  ReportsState({this.data, this.reportKind});
}

class ReportsNotifier extends AutoDisposeAsyncNotifier<ReportsState> {
  @override
  FutureOr<ReportsState> build() {
    return ReportsState();
  }

  Future<void> runReport({
    required String kind,
    String? from,
    String? to,
    String? group,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(financeRepositoryProvider);
      final groupParam = (kind == 'revenue' && group != 'none') ? group : null;
      final data = await repository.getReports(kind, from: from, to: to, group: groupParam);
      return ReportsState(data: data, reportKind: kind);
    });
  }

  void clear() {
    state = AsyncValue.data(ReportsState());
  }
}

final reportsProvider = AsyncNotifierProvider.autoDispose<ReportsNotifier, ReportsState>(() {
  return ReportsNotifier();
});
