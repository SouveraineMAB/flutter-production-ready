
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/data/task_repository.dart';
import 'package:focus_flow/models/task.dart';

void main() {
  TaskRepository repository() => TaskRepository(const [
        Task(
            id: '1',
            title: 'Write report',
            category: 'Work',
            priority: TaskPriority.high,
            minutes: 30),
        Task(
            id: '2',
            title: 'Read book',
            category: 'Learning',
            priority: TaskPriority.low,
            minutes: 20),
        Task(
            id: '3',
            title: 'Walk',
            category: 'Health',
            priority: TaskPriority.medium,
            minutes: 15,
            isCompleted: true),
      ]);

  test('returns all seeded tasks',
      () => expect(repository().getAll(), hasLength(3)));
  test('returns completed tasks',
      () => expect(repository().getCompleted().single.id, '3'));
  test('searches titles case insensitively',
      () => expect(repository().search('REPORT').single.id, '1'));
  test('searches categories',
      () => expect(repository().search('health').single.id, '3'));
  test('empty search returns all tasks',
      () => expect(repository().search(''), hasLength(3)));
  test('toggle completes an open task', () {
    final item = repository();
    expect(item.toggle('1'), isTrue);
    expect(item.getCompleted(), hasLength(2));
  });
  test('toggle reopens a completed task', () {
    final item = repository();
    item.toggle('3');
    expect(item.getCompleted(), isEmpty);
  });
  test('toggle unknown id returns false',
      () => expect(repository().toggle('missing'), isFalse));
  test('sums planned minutes', () => expect(repository().totalMinutes, 65));
  test('calculates completion rate',
      () => expect(repository().completionRate, closeTo(1 / 3, .001)));
  test('copyWith preserves immutable fields', () {
    final item = repository().getAll().first.copyWith(isCompleted: true);
    expect(item.title, 'Write report');
    expect(item.isCompleted, isTrue);
  });
  test('empty repositories have zero completion rate',
 
      () => expect(TaskRepository(const []).completionRate, 0));

      test('adds a new task', () {
  final repository = TaskRepository();

  const task = Task(
    id: '5',
    title: 'Learn Flutter',
    category: 'Learning',
    priority: TaskPriority.high,
    minutes: 60,
  );

  expect(repository.add(task), isTrue);
  expect(repository.getAll(), contains(task));
});

test('does not add a task with an existing id', () {
  final repository = TaskRepository();

  const task = Task(
    id: '1',
    title: 'Another task',
    category: 'Work',
    priority: TaskPriority.low,
    minutes: 15,
  );

  expect(repository.add(task), isFalse);
  expect(repository.getAll().length, 4);
});

test('updates an existing task', () {
  final repository = TaskRepository();

  const updatedTask = Task(
    id: '1',
    title: 'Updated task',
    category: 'Learning',
    priority: TaskPriority.medium,
    minutes: 50,
  );

  expect(repository.update(updatedTask), isTrue);
  expect(repository.getAll().first.title, 'Updated task');
  expect(repository.getAll().first.minutes, 50);
});

test('does not update an unknown task', () {
  final repository = TaskRepository();

  const task = Task(
    id: '99',
    title: 'Unknown task',
    category: 'Work',
    priority: TaskPriority.low,
    minutes: 10,
  );

  expect(repository.update(task), isFalse);
});

test('deletes an existing task', () {
  final repository = TaskRepository();

  expect(repository.delete('1'), isTrue);
  expect(repository.getAll().length, 3);
  expect(
    repository.getAll().any((task) => task.id == '1'),
    isFalse,
  );
});

test('does not delete an unknown task', () {
  final repository = TaskRepository();

  expect(repository.delete('99'), isFalse);
  expect(repository.getAll().length, 4);
});

test('ajoute une nouvelle tâche', () {
  final repository = TaskRepository();

  const task = Task(
    id: '5',
    title: 'Learn Flutter',
    category: 'Learning',
    priority: TaskPriority.high,
    minutes: 60,
  );

  expect(repository.add(task), isTrue);
  expect(repository.getAll(), contains(task));
});

test('refuse une tâche avec un identifiant existant', () {
  final repository = TaskRepository();

  const task = Task(
    id: '1',
    title: 'Another task',
    category: 'Work',
    priority: TaskPriority.low,
    minutes: 15,
  );

  expect(repository.add(task), isFalse);
  expect(repository.getAll().length, 4);
});

test('modifie une tâche existante', () {
  final repository = TaskRepository();

  const updatedTask = Task(
    id: '1',
    title: 'Updated task',
    category: 'Learning',
    priority: TaskPriority.medium,
    minutes: 50,
  );

  expect(repository.update(updatedTask), isTrue);
  expect(repository.getAll().first.title, 'Updated task');
  expect(repository.getAll().first.minutes, 50);
});

test('supprime une tâche existante', () {
  final repository = TaskRepository();

  expect(repository.delete('1'), isTrue);
  expect(repository.getAll().length, 3);
});
}


