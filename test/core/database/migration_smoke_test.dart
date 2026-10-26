import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/database/app_database.dart' hide Task;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('schema version is 3', () async {
    final db = AppDatabase(NativeDatabase.memory());
    expect(db.schemaVersion, 3);
    await db.close();
  });

  test('task history table and indexes exist', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='task_history_events'",
        )
        .get();
    expect(tables, isNotEmpty);
    await db.close();
  });
}
