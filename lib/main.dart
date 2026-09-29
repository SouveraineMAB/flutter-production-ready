import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/task_repository.dart';
import 'l10n/app_localizations.dart';
import 'models/task.dart';

void main() {
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatefulWidget {
  const FocusFlowApp({super.key});

  @override
  State<FocusFlowApp> createState() => _FocusFlowAppState();
}

class _FocusFlowAppState extends State<FocusFlowApp> {
  Locale _locale = const Locale('en');
  final TaskRepository _repository = TaskRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Flow',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff176b5d),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfff7f8f5),
        useMaterial3: true,
        fontFamily: 'sans',
      ),
      home: AppShell(
        repository: _repository,
        onLocaleChanged: (locale) {
          setState(() {
            _locale = locale;
          });
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    required this.repository,
    required this.onLocaleChanged,
    super.key,
  });

  final TaskRepository repository;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final pages = [
      DashboardPage(
        repository: widget.repository,
        onOpenTasks: () => setState(() => _index = 1),
      ),
      TasksPage(repository: widget.repository),
      FocusPage(repository: widget.repository),
      InsightsPage(repository: widget.repository),
      SettingsPage(onLocaleChanged: widget.onLocaleChanged),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: l10n.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.focus,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.insights,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.repository,
    required this.onOpenTasks,
    super.key,
  });

  final TaskRepository repository;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tasks = repository.getAll();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.goodMorning,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.todayPlan,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: _ProgressCard(repository: repository),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.today,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: onOpenTasks,
                    child: Text(l10n.allTasks),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            sliver: SliverList.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskTile(
                  task: tasks[index],
                  onChanged: (_) {
                    repository.toggle(tasks[index].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.repository});

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff176b5d),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                value: repository.completionRate,
                strokeWidth: 8,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${repository.completedCount}/${repository.getAll().length}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${AppLocalizations.of(context).completed} • '
                    '${repository.totalMinutes} '
                    '${AppLocalizations.of(context).minutesFocused}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${AppLocalizations.of(context).markDone}: ${task.title}',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: task.isCompleted,
          onChanged: onChanged,
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${task.category} • ${task.minutes} min',
          ),
          secondary: onEdit == null && onDelete == null
              ? Icon(
                  task.priority == TaskPriority.high
                      ? Icons.priority_high
                      : Icons.flag_outlined,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      task.priority == TaskPriority.high
                          ? Icons.priority_high
                          : Icons.flag_outlined,
                    ),
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        tooltip: 'Modifier la tâche',
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'Supprimer la tâche',
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({
    required this.repository,
    super.key,
  });

  final TaskRepository repository;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _query = '';

  Future<void> _addTask() async {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final minutesController = TextEditingController();

    TaskPriority selectedPriority = TaskPriority.medium;

    final task = await showDialog<Task>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ajouter une tâche'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        hintText: 'Ex. Apprendre Flutter',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        hintText: 'Ex. Formation',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durée (minutes)',
                        hintText: 'Ex. 60',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priorité',
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final category = categoryController.text.trim();
                    final minutes = int.tryParse(minutesController.text);

                    if (title.isEmpty ||
                        category.isEmpty ||
                        minutes == null ||
                        minutes <= 0) {
                      return;
                    }

                    Navigator.pop(
                      context,
                      Task(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        title: title,
                        category: category,
                        priority: selectedPriority,
                        minutes: minutes,
                      ),
                    );
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    categoryController.dispose();
    minutesController.dispose();

    if (task != null) {
      widget.repository.add(task);
      setState(() {});
    }
  }

  Future<void> _editTask(Task task) async {
    final titleController = TextEditingController(text: task.title);
    final categoryController = TextEditingController(text: task.category);
    final minutesController =
        TextEditingController(text: task.minutes.toString());

    TaskPriority selectedPriority = task.priority;

    final updatedTask = await showDialog<Task>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Modifier la tâche'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durée (minutes)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priorité',
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final category = categoryController.text.trim();
                    final minutes = int.tryParse(minutesController.text);

                    if (title.isEmpty ||
                        category.isEmpty ||
                        minutes == null ||
                        minutes <= 0) {
                      return;
                    }

                    Navigator.pop(
                      context,
                      task.copyWith(
                        title: title,
                        category: category,
                        priority: selectedPriority,
                        minutes: minutes,
                      ),
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    categoryController.dispose();
    minutesController.dispose();

    if (updatedTask != null) {
      widget.repository.update(updatedTask);
      setState(() {});
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la tâche'),
          content: Text(
            'Voulez-vous vraiment supprimer "${task.title}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.repository.delete(task.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tasks = widget.repository.search(_query);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.tasks,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton.filled(
                  onPressed: _addTask,
                  tooltip: 'Ajouter une tâche',
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Semantics(
              label: l10n.chooseTask,
              textField: true,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.chooseTask,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(l10n.noTasks),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskTile(
                        task: tasks[index],
                        onChanged: (_) {
                          widget.repository.toggle(tasks[index].id);
                          setState(() {});
                        },
                        onEdit: () => _editTask(tasks[index]),
                        onDelete: () => _deleteTask(tasks[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class FocusPage extends StatelessWidget {
  const FocusPage({
    required this.repository,
    super.key,
  });

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.focus,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: .72,
                    strokeWidth: 14,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  '25:00',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(l10n.startFocus),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.startFocus),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InsightsPage extends StatelessWidget {
  const InsightsPage({
    required this.repository,
    super.key,
  });

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.insights,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.weeklyProgress,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        7,
                        (index) => Container(
                          width: 25,
                          height: 40.0 + index * 13,
                          decoration: BoxDecoration(
                            color: index == 6
                                ? const Color(0xff176b5d)
                                : const Color(0xffb4d9cf),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '${repository.totalMinutes} ${l10n.minutesFocused}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.statistics,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: Text(
              '${repository.completedCount} ${l10n.completed}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(
              '${repository.totalMinutes} ${l10n.minutesFocused}',
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.onLocaleChanged,
    super.key,
  });

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.preferences,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              Localizations.localeOf(context).languageCode == 'fr'
                  ? l10n.french
                  : l10n.english,
            ),
          ),
          SegmentedButton<Locale>(
            segments: [
              ButtonSegment(
                value: const Locale('en'),
                label: Text(l10n.english),
              ),
              ButtonSegment(
                value: const Locale('fr'),
                label: Text(l10n.french),
              ),
            ],
            selected: {
              Localizations.localeOf(context).languageCode == 'fr'
                  ? const Locale('fr')
                  : const Locale('en'),
            },
            onSelectionChanged: (value) {
              onLocaleChanged(value.first);
            },
          ),
        ],
      ),
    );
  }
}