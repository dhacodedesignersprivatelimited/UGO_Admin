// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ugo_admin/shared/admin_panel_dependencies.dart';
import 'package:ugo_admin/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AdminPanelDependencies>(
        create: (_) => AdminPanelDependencies.mock(),
        child: MyApp(),
      ),
    );
    // Flush splash/auth fallback timer in [MyApp.initState].
    await tester.pump(const Duration(milliseconds: 600));
  });
}
