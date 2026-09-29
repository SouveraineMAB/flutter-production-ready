enum TaskPriority { low, medium, high }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.minutes,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String category;
  final TaskPriority priority;
  final int minutes;
  final bool isCompleted;

  Task copyWith({
    String? title,
    String? category,
    TaskPriority? priority,
    int? minutes,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      minutes: minutes ?? this.minutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}