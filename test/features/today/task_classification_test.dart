import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/today/domain/today_task_classification.dart';

Task mk({required String id, TaskStatus status=TaskStatus.pending, TaskPriority priority=TaskPriority.medium, DateTime? due, DateTime? completed}) => Task(
  id: id, title: id, status: status, priority: priority, dueDate: due,
  createdAt: DateTime(2026,1,1), updatedAt: DateTime(2026,1,1), completedAt: completed);

void main() {
  final now = DateTime(2026,10,26,14,30);
  test('basic', () {
    final tasks = [
      mk(id:'h-future', priority:TaskPriority.high, due:DateTime(2026,10,30)),
      mk(id:'none', priority:TaskPriority.high),
      mk(id:'due-today', due:DateTime(2026,10,26,9,0)),
      mk(id:'overdue', due:DateTime(2026,10,20)),
      mk(id:'done-today', status:TaskStatus.completed, completed:DateTime(2026,10,26,10,0)),
      mk(id:'done-other', status:TaskStatus.completed, completed:DateTime(2026,10,25,10,0)),
    ];
    final r = classifyTasks(tasks, now);
    expect(r.focus.map((t)=>t.id), containsAll(['h-future','none']));
    expect(r.dueToday.map((t)=>t.id), contains('due-today'));
    expect(r.overdue.map((t)=>t.id), contains('overdue'));
    expect(r.completedToday.map((t)=>t.id), contains('done-today'));
    expect(r.completedToday.map((t)=>t.id), isNot(contains('done-other')));
  });
  test('no duplicates', () {
    final tasks = [mk(id:'h-today', priority:TaskPriority.high, due:DateTime(2026,10,26,9,0))];
    final r = classifyTasks(tasks, now);
    expect(r.focus.length,1);
    expect(r.dueToday.length,0);
  });
  test('calendar boundary', () {
    final n = DateTime(2026,10,26,0,0,1);
    final tasks = [mk(id:'late-yesterday', due:DateTime(2026,10,25,23,59))];
    final r = classifyTasks(tasks, n);
    expect(r.overdue.map((t)=>t.id), contains('late-yesterday'));
  });
}
