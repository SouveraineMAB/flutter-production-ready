import '../models/task.dart';

class TaskRepository {
  TaskRepository([List<Task>? seed])
      : _tasks = List.of(seed ?? _defaultTasks);

  final List<Task> _tasks;

  List<Task> getAll() => List.unmodifiable(_tasks);

  List<Task> getCompleted() => List.unmodifiable(
        _tasks.where((task) => task.isCompleted),
      );

  List<Task> search(String query) {
    final normalized = query.trim().toLowerCase();

    if (normalized.isEmpty) {
      return getAll();
    }

    return List.unmodifiable(
      _tasks.where(
        (task) =>
            task.title.toLowerCase().contains(normalized) ||
            task.category.toLowerCase().contains(normalized),
      ),
    );
  }

  bool add(Task task) {
    final alreadyExists = _tasks.any((item) => item.id == task.id);

    if (alreadyExists) {
      return false;
    }

    _tasks.add(task);
    return true;
  }

  bool update(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) {
      return false;
    }

    _tasks[index] = task;
    return true;
  }

  bool delete(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) {
      return false;
    }

    _tasks.removeAt(index);
    return true;
  }

  bool toggle(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) {
      return false;
    }

    _tasks[index] = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
    );

    return true;
  }

  int get totalMinutes =>
      _tasks.fold(0, (sum, task) => sum + task.minutes);

  int get completedCount => getCompleted().length;

  double get completionRate =>
      _tasks.isEmpty ? 0 : completedCount / _tasks.length;

  static const _defaultTasks = <Task>[
    Task(
      id: '1',
      title: 'Plan the week',
      category: 'Planning',
      priority: TaskPriority.high,
      minutes: 20,
    ),
    Task(
      id: '2',
      title: 'Review product brief',
      category: 'Work',
      priority: TaskPriority.medium,
      minutes: 45,
    ),
    Task(
      id: '3',
      title: 'Read 10 pages',
      category: 'Learning',
      priority: TaskPriority.low,
      minutes: 25,
    ),
    Task(
      id: '4',
      title: 'Prepare team sync',
      category: 'Work',
      priority: TaskPriority.high,
      minutes: 30,
    ),
  ];
}