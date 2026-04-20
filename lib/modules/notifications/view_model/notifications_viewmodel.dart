import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/network/api_calls.dart';
import '/core/auth/auth_util.dart';
import '/core/utils/view_state.dart';
import 'notifications_state.dart';

export 'notifications_state.dart';

/// ViewModel for the push-notification composer screen.
class NotificationsViewModel extends StateNotifier<NotificationsState> {
  NotificationsViewModel() : super(const NotificationsState());

  void updateTitle(String value) => state = state.copyWith(title: value);
  void updateBody(String value) => state = state.copyWith(body: value);
  void updateAudience(String value) =>
      state = state.copyWith(targetAudience: value);

  Future<void> send() async {
    if (state.title.isEmpty || state.body.isEmpty) return;
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final token = currentAuthenticationToken ?? '';
      await SendNotificationCall.call(
        token: token,
        title: state.title,
        message: state.body,
        target: state.targetAudience,
      );
      state = state.copyWith(
        status: LoadStatus.success,
        sentCount: state.sentCount + 1,
        title: '',
        body: '',
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  void reset() => state = const NotificationsState();
}

/// Global notifications ViewModel provider.
final notificationsViewModelProvider =
    StateNotifierProvider<NotificationsViewModel, NotificationsState>(
  (_) => NotificationsViewModel(),
);
