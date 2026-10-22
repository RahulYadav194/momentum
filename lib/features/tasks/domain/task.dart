import 'package:momentum/core/database/tables/tasks.dart'
    show TaskPriority, TaskStatus;

/// A task in the user's personal task list.
///
/// This is the domain model used throughout the application. It is deliberately
/// decoupled from the Drift row model so that the domain layer does not depend
/// on the persistence layer.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// Locally generated stable identifier (UUID v4).
  final String id;

  /// The task title, already trimmed of surrounding whitespace.
  final String title;

  /// Optional free-form description.
  final String? description;

  /// Lifecycle state of the task.
  final TaskStatus status;

  /// Relative importance of the task.
  final TaskPriority priority;

  /// Optional local deadline.
  final DateTime? dueDate;

  /// When the task was first created.
  final DateTime createdAt;

  /// When the task was last modified.
  final DateTime updatedAt;

  /// When the task was marked as completed, if ever.
  final DateTime? completedAt;

  /// Whether the task has been completed.
  bool get isCompleted => status == TaskStatus.completed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          status == other.status &&
          priority == other.priority &&
          dueDate == other.dueDate &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          completedAt == other.completedAt;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        status,
        priority,
        dueDate,
        createdAt,
        updatedAt,
        completedAt,
      );

  @override
  String toString() =>
      'Task(id: $id, title: $title, status: $status, priority: $priority)';
}

/// Input for creating a new task.
///
/// Only [title] is required; the remaining fields are optional and fall back
/// to sensible defaults when omitted.
class TaskDraft {
  const TaskDraft({
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  /// The task title. Surrounding whitespace is trimmed by the repository.
  final String title;

  /// Optional free-form description.
  final String? description;

  /// Relative importance. Defaults to [TaskPriority.medium].
  final TaskPriority priority;

  /// Optional local deadline.
  final DateTime? dueDate;
}

/// Partial update for an existing task.
///
/// A `null` value for a field means "leave it unchanged". The boolean flags
/// [clearDescription] and [clearDueDate] allow explicitly clearing those
/// optional fields, since `null` alone is ambiguous.
class TaskUpdate {
  const TaskUpdate({
    this.title,
    this.description,
    this.clearDescription = false,
    this.priority,
    this.dueDate,
    this.clearDueDate = false,
    this.status,
  });

  /// New title. Surrounding whitespace is trimmed by the repository.
  final String? title;

  /// New description.
  final String? description;

  /// When true, clears the description regardless of [description].
  final bool clearDescription;

  /// New priority.
  final TaskPriority? priority;

  /// New due date.
  final DateTime? dueDate;

  /// When true, clears the due date regardless of [dueDate].
  final bool clearDueDate;

  /// New status.
  final TaskStatus? status;
}
