/// Status of any async operation — shared across all Riverpod ViewModels.
/// Replaces [BlocLoadStatus] / [Loadable] from the old architecture.
enum LoadStatus { initial, loading, success, failure }

/// Convenience getters mixed into every feature state.
mixin LoadStateMixin {
  LoadStatus get status;
  String? get errorMessage;

  bool get isInitial => status == LoadStatus.initial;
  bool get isLoading => status == LoadStatus.loading;
  bool get isSuccess => status == LoadStatus.success;
  bool get isFailure => status == LoadStatus.failure;
}
