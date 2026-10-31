import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/today/domain/today_task_classification.dart';

Task makeTask({
  required String id,
  TaskStatus status = TaskStatus.pending,
  TaskPriority priority = TaskPriority.medium,
  DateTime? plannedDate,
  DateTime? dueDate,
  DateTime? completedAt,
}) => Task(
  id: id,
  title: id,
  status: status,
  priority: priority,
  plannedDate: plannedDate,
  dueDate: dueDate,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  completedAt: completedAt,
);

void main() {
  final DateTime today = DateTime(2026, 10, 26, 14, 30);
  final DateTime todayDate = DateTime(2026, 10, 26);

  test('classifies by plan date, deadline, and priority precedence', () {
    final List<Task> tasks = <Task>[
      makeTask(id: 'planned', plannedDate: DateTime(2026, 10, 26, 9)),
      makeTask(id: 'missed', plannedDate: DateTime(2026, 10, 25)),
      makeTask(id: 'future-plan', plannedDate: DateTime(2026, 10, 27)),
      makeTask(id: 'due', dueDate: DateTime(2026, 10, 26, 18)),
      makeTask(id: 'overdue', dueDate: DateTime(2026, 10, 25)),
      makeTask(id: 'suggested', priority: TaskPriority.high),
      makeTask(id: 'medium-unscheduled'),
      makeTask(id: 'low-unscheduled', priority: TaskPriority.low),
      makeTask(
        id: 'planned-and-due-today',
        plannedDate: todayDate,
        dueDate: todayDate,
      ),
      makeTask(
        id: 'missed-and-overdue',
        plannedDate: DateTime(2026, 10, 24),
        dueDate: DateTime(2026, 10, 25),
      ),
      makeTask(id: 'future-deadline', dueDate: DateTime(2026, 10, 30)),
    ];

    final TodayTaskSections sections = classifyTasks(tasks, today);

    expect(_ids(sections.plannedToday), <String>[
      'planned-and-due-today',
      'planned',
    ]);
    expect(_ids(sections.missedPlans), <String>[
      'missed-and-overdue',
      'missed',
    ]);
    expect(_ids(sections.overdue), <String>['overdue']);
    expect(_ids(sections.dueToday), <String>['due']);
    expect(_ids(sections.suggestedForToday), <String>['suggested']);
    expect(_ids(sections.upcoming), <String>['future-plan', 'future-deadline']);
    expect(_ids(sections.unscheduled), <String>[
      'low-unscheduled',
      'medium-unscheduled',
    ]);

    final List<Task> classifiedTasks = <Task>[
      ...sections.plannedToday,
      ...sections.missedPlans,
      ...sections.overdue,
      ...sections.dueToday,
      ...sections.suggestedForToday,
      ...sections.upcoming,
      ...sections.unscheduled,
    ];
    expect(classifiedTasks, hasLength(tasks.length));
    expect(
      classifiedTasks.map((Task task) => task.id).toSet(),
      hasLength(tasks.length),
    );
  });

  test(
    'completed tasks only appear in Completed Today on their completion date',
    () {
      final List<Task> tasks = <Task>[
        makeTask(
          id: 'completed-today',
          status: TaskStatus.completed,
          plannedDate: DateTime(2026, 10, 20),
          dueDate: DateTime(2026, 10, 21),
          completedAt: DateTime(2026, 10, 26, 10),
        ),
        makeTask(
          id: 'completed-earlier',
          status: TaskStatus.completed,
          plannedDate: DateTime(2026, 10, 20),
          dueDate: DateTime(2026, 10, 21),
          completedAt: DateTime(2026, 10, 25, 10),
        ),
        makeTask(
          id: 'missing-completion-date',
          status: TaskStatus.completed,
          plannedDate: DateTime(2026, 10, 20),
        ),
      ];

      final TodayTaskSections sections = classifyTasks(tasks, today);

      expect(_ids(sections.completedToday), <String>['completed-today']);
      expect(sections.relevantTasks, isEmpty);
      expect(sections.missedPlans, isEmpty);
      expect(sections.overdue, isEmpty);
    },
  );

  test(
    'reopened tasks are classified using their current dates and priority',
    () {
      final Task reopened = makeTask(
        id: 'reopened',
        status: TaskStatus.pending,
        plannedDate: DateTime(2026, 10, 25),
        completedAt: null,
      );

      final TodayTaskSections sections = classifyTasks(<Task>[reopened], today);

      expect(_ids(sections.missedPlans), <String>['reopened']);
      expect(sections.completedToday, isEmpty);
    },
  );
}

List<String> _ids(List<Task> tasks) =>
    tasks.map((Task task) => task.id).toList();
