import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/finance_repository.dart';

final earningsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return repository.getDashboardStats();
});
