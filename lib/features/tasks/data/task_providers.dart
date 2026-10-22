import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../domain/task_repository.dart';
import 'drift_task_repository.dart';

/// Provides the task repository to the widget tree.
///
/// Reuses [appDatabaseProvider] so the database lifecycle is managed in one
/// place. The repository is created lazily and shares the database instance.
final Provider<TaskRepository> taskRepositoryProvider =
    Provider<TaskRepository>((Ref ref) {
  final AppDatabase database = ref.watch(appDatabaseProvider);
  return DriftTaskRepository(database);
});
