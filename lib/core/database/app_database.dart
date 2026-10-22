import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/tasks.dart';

part 'app_database.g.dart';

/// The application database.
///
/// Uses Drift on top of SQLite. The production connection is created through
/// [driftDatabase], which applies the Android-specific workaround for opening
/// sqlite3 on older Android versions. Tests can inject an in-memory
/// [QueryExecutor] through the constructor.
@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  /// Creates a database backed by [executor].
  ///
  /// When [executor] is omitted, a production connection is created through
  /// [driftDatabase]. Pass [NativeDatabase.memory] (from
  /// `package:drift/native.dart`) in tests for an isolated in-memory database.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'momentum'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Create every table on a fresh database.
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    // Existing installations are upgraded here. Version 1 is the initial
    // schema, so there is nothing to migrate yet.
    onUpgrade: (Migrator m, int from, int to) async {
      // Future schema changes are handled here, one version at a time.
    },
  );
}

/// Provides the application database to the widget tree.
///
/// The database is created lazily and closed when the provider is disposed,
/// so a single instance is shared across the app and never leaked.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});
