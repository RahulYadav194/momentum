import 'package:momentum/core/database/tables/task_history_events.dart'
    show TaskHistoryEventType;

/// A single append-only history event for a task.
class TaskHistoryEvent {
  const TaskHistoryEvent({
    required this.id,
    required this.taskId,
    required this.eventType,
    required this.occurredAt,
    this.previousPlannedDate,
    this.newPlannedDate,
    this.previousDueDate,
    this.newDueDate,
    this.previousStatus,
    this.newStatus,
  });

  final String id;
  final String taskId;
  final TaskHistoryEventType eventType;
  final DateTime occurredAt;
  final DateTime? previousPlannedDate;
  final DateTime? newPlannedDate;
  final DateTime? previousDueDate;
  final DateTime? newDueDate;
  final String? previousStatus;
  final String? newStatus;
}
