import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:momentum/core/database/app_database.dart' hide Task;
import 'package:momentum/features/tasks/data/drift_task_repository.dart';
import 'package:momentum/features/tasks/domain/task.dart';
import 'package:momentum/features/tasks/domain/task_repository.dart';

/// Provides the task repository to the widget tree.
///
/// Reuses [appDatabaseProvider] so the database lifecycle is managed in one
/// place. The repository is created lazily and shares the database instance.
final Provider<TaskRepository> taskRepositoryProvider =
    Provider<TaskRepository>((Ref ref) {
      final AppDatabase database = ref.watch(appDatabaseProvider);
      return DriftTaskRepository(database);
    });

/// A reactive stream of all tasks, ordered by creation time (newest first).
final StreamProvider<List<Task>> taskListProvider = StreamProvider<List<Task>>((
  Ref ref,
) {
  final TaskRepository repository = ref.watch(taskRepositoryProvider);
  return repository.watchAll();
});
