import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/tasks/data/task_providers.dart';
import 'package:momentum/features/tasks/domain/task.dart';

import 'helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('starts on the Today tab with the tabbed shell', (
    WidgetTester tester,
  ) async {
    final preferences = await createTestPreferences(<String, Object>{});

    await tester.pumpWidget(
      buildTestApp(
        preferences: preferences,
        overrides: [
          taskListProvider.overrideWith((Ref ref) => Stream.value(<Task>[])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Today'), findsOneWidget);
    expect(find.text('Nothing planned for today'), findsOneWidget);
  });
}
