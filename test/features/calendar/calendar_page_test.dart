import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/calendar/calendar_page.dart';
import 'package:momentum/features/tasks/data/task_providers.dart';

import '../../helpers/fake_task_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('calendar renders month header', (tester) async {
    final repo = FakeTaskRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: CalendarPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    repo.dispose();
  });
}
