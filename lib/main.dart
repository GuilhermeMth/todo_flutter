import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = TodoDatabase();
  await database.open();
  final notifications = NotificationService();
  await notifications.initialize();
  runApp(TodoApp(database: database, notifications: notifications));
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
    this.dueDateTime,
    this.categoryId,
  });

  final int? id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;
  final DateTime? dueDateTime;
  final int? categoryId;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'completed': completed ? 1 : 0,
    'due_date_time': dueDateTime?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'category_id': categoryId,
  };

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as int,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    completed: (map['completed'] as int) == 1,
    dueDateTime: map['due_date_time'] == null
        ? null
        : DateTime.parse(map['due_date_time'] as String),
    createdAt: DateTime.parse(map['created_at'] as String),
    categoryId: map['category_id'] as int?,
  );
}

class Category {
  const Category({required this.id, required this.name});

  final int? id;
  final String name;

  Map<String, Object?> toMap() => {if (id != null) 'id': id, 'name': name};

  factory Category.fromMap(Map<String, Object?> map) =>
      Category(id: map['id'] as int, name: map['name'] as String);
}

class TodoDatabase {
  Database? _database;

  Future<void> open() async {
    final databasesPath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(databasesPath, 'todo_app.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            completed INTEGER NOT NULL DEFAULT 0,
            due_date_time TEXT,
            created_at TEXT NOT NULL,
            category_id INTEGER,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
          )
        ''');
      },
    );
    await _database!.execute('PRAGMA foreign_keys = ON');
  }

  Database get db => _database!;

  Future<List<Task>> tasks() async {
    final rows = await db.query(
      'tasks',
      orderBy: 'completed ASC, due_date_time ASC, created_at DESC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<int> saveTask(Task task) async {
    if (task.id == null) return db.insert('tasks', task.toMap());
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task.id!;
  }

  Future<void> deleteTask(int id) =>
      db.delete('tasks', where: 'id = ?', whereArgs: [id]);

  Future<List<Category>> categories() async {
    final rows = await db.query('categories', orderBy: 'name COLLATE NOCASE');
    return rows.map(Category.fromMap).toList();
  }

  Future<int> saveCategory(Category category) async {
    if (category.id == null) return db.insert('categories', category.toMap());
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    return category.id!;
  }

  Future<void> deleteCategory(int id) =>
      db.delete('categories', where: 'id = ?', whereArgs: [id]);
}

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> schedule(Task task) async {
    if (task.id == null ||
        task.completed ||
        task.dueDateTime == null ||
        !task.dueDateTime!.isAfter(DateTime.now())) {
      if (task.id != null) await cancel(task.id!);
      return;
    }
    await cancel(task.id!);
    await _plugin.zonedSchedule(
      task.id!,
      'Tarefa pendente',
      task.title,
      _toTZDateTime(task.dueDateTime!),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_due_dates',
          'Lembretes de tarefas',
          channelDescription:
              'Notificações para tarefas com data de vencimento',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  tz.TZDateTime _toTZDateTime(DateTime value) =>
      tz.TZDateTime.from(value, tz.local);
}

class TodoApp extends StatelessWidget {
  const TodoApp({
    super.key,
    required this.database,
    required this.notifications,
  });
  final TodoDatabase database;
  final NotificationService notifications;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Minhas tarefas',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315f72)),
      useMaterial3: true,
    ),
    home: TaskListScreen(database: database, notifications: notifications),
  );
}

enum TaskFilter { all, pending, completed }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    required this.database,
    required this.notifications,
  });
  final TodoDatabase database;
  final NotificationService notifications;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  List<Category> _categories = [];
  TaskFilter _filter = TaskFilter.all;
  int? _categoryFilter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final tasks = await widget.database.tasks();
      final categories = await widget.database.categories();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _categories = categories;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Não foi possível carregar os dados: $error');
      }
    }
  }

  void _showError(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _openEditor([Task? task]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskEditorScreen(
          database: widget.database,
          notifications: widget.notifications,
          task: task,
          categories: _categories,
        ),
      ),
    );
    _reload();
  }

  List<Task> get _visibleTasks => _tasks.where((task) {
    final status =
        _filter == TaskFilter.all ||
        (_filter == TaskFilter.completed ? task.completed : !task.completed);
    return status &&
        (_categoryFilter == null || task.categoryId == _categoryFilter);
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
        actions: [
          IconButton(
            tooltip: 'Categorias',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      CategoryManagementScreen(database: widget.database),
                ),
              );
              _reload();
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  SegmentedButton<TaskFilter>(
                    segments: const [
                      ButtonSegment(
                        value: TaskFilter.all,
                        label: Text('Todas'),
                      ),
                      ButtonSegment(
                        value: TaskFilter.pending,
                        label: Text('Pendentes'),
                      ),
                      ButtonSegment(
                        value: TaskFilter.completed,
                        label: Text('Concluídas'),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (value) =>
                        setState(() => _filter = value.first),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: _categoryFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todas as categorias'),
                      ),
                      ..._categories.map(
                        (category) => DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _categoryFilter = value),
                  ),
                  const SizedBox(height: 16),
                  if (_visibleTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('Nenhuma tarefa encontrada.')),
                    )
                  else
                    ..._visibleTasks.map(_taskTile),
                ],
              ),
            ),
    );
  }

  Widget _taskTile(Task task) {
    final category = _categories
        .where((item) => item.id == task.categoryId)
        .firstOrNull;
    return Card(
      child: ListTile(
        onTap: () => _openEditor(task),
        leading: Checkbox(
          value: task.completed,
          onChanged: (value) async {
            final updated = Task(
              id: task.id,
              title: task.title,
              description: task.description,
              completed: value ?? false,
              dueDateTime: task.dueDateTime,
              createdAt: task.createdAt,
              categoryId: task.categoryId,
            );
            await widget.database.saveTask(updated);
            await widget.notifications.schedule(updated);
            _reload();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.completed ? 'Concluída' : 'Pendente'),
            if (category != null) Text(category.name),
            if (task.dueDateTime != null)
              Text(
                'Vence em ${DateFormat('dd/MM/yyyy HH:mm').format(task.dueDateTime!)}',
              ),
          ],
        ),
        isThreeLine: category != null || task.dueDateTime != null,
      ),
    );
  }
}

class TaskEditorScreen extends StatefulWidget {
  const TaskEditorScreen({
    super.key,
    required this.database,
    required this.notifications,
    required this.categories,
    this.task,
  });
  final TodoDatabase database;
  final NotificationService notifications;
  final List<Category> categories;
  final Task? task;

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late bool _completed;
  DateTime? _dueDateTime;
  int? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title);
    _description = TextEditingController(text: task?.description);
    _completed = task?.completed ?? false;
    _dueDateTime = task?.dueDateTime;
    _categoryId = task?.categoryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseDueDateTime() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final storedDate = _dueDateTime == null
        ? firstDate
        : DateTime(_dueDateTime!.year, _dueDateTime!.month, _dueDateTime!.day);
    final date = await showDatePicker(
      context: context,
      initialDate: storedDate.isBefore(firstDate) ? firstDate : storedDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDateTime ?? DateTime.now()),
    );
    if (time != null) {
      setState(
        () => _dueDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Informe um título.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final task = Task(
        id: widget.task?.id,
        title: title,
        description: _description.text.trim(),
        completed: _completed,
        dueDateTime: _dueDateTime,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        categoryId: _categoryId,
      );
      final id = await widget.database.saveTask(task);
      await widget.notifications.schedule(
        Task(
          id: id,
          title: task.title,
          description: task.description,
          completed: task.completed,
          dueDateTime: task.dueDateTime,
          createdAt: task.createdAt,
          categoryId: task.categoryId,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $error')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final id = widget.task?.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.database.deleteTask(id);
      await widget.notifications.cancel(id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa'),
      actions: [
        if (widget.task != null)
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
          ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _title,
          autofocus: widget.task == null,
          decoration: const InputDecoration(
            labelText: 'Título *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int?>(
          initialValue: _categoryId,
          decoration: const InputDecoration(
            labelText: 'Categoria (opcional)',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Sem categoria'),
            ),
            ...widget.categories.map(
              (category) => DropdownMenuItem<int?>(
                value: category.id,
                child: Text(category.name),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _categoryId = value),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Concluída'),
          value: _completed,
          onChanged: (value) => setState(() => _completed = value),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _dueDateTime == null
                ? 'Sem lembrete'
                : DateFormat('dd/MM/yyyy HH:mm').format(_dueDateTime!),
          ),
          subtitle: const Text('Data e hora de vencimento'),
          leading: const Icon(Icons.event_outlined),
          trailing: _dueDateTime == null
              ? const Icon(Icons.chevron_right)
              : IconButton(
                  onPressed: () => setState(() => _dueDateTime = null),
                  icon: const Icon(Icons.clear),
                ),
          onTap: _chooseDueDateTime,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: const Text('Salvar'),
        ),
      ],
    ),
  );
}

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key, required this.database});
  final TodoDatabase database;

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final categories = await widget.database.categories();
      if (mounted) setState(() => _categories = categories);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $error')),
        );
      }
    }
  }

  Future<void> _edit([Category? category]) async {
    final controller = TextEditingController(text: category?.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Nova categoria' : 'Renomear categoria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      await widget.database.saveCategory(
        Category(id: category?.id, name: name),
      );
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível salvar a categoria: $error'),
          ),
        );
      }
    }
  }

  Future<void> _delete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria?'),
        content: const Text(
          'As tarefas continuarão salvas, mas ficarão sem categoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && category.id != null) {
      await widget.database.deleteCategory(category.id!);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Categorias')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _edit,
      icon: const Icon(Icons.add),
      label: const Text('Nova categoria'),
    ),
    body: _categories.isEmpty
        ? const Center(child: Text('Nenhuma categoria criada.'))
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(category.name),
                trailing: Wrap(
                  children: [
                    IconButton(
                      onPressed: () => _edit(category),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Renomear',
                    ),
                    IconButton(
                      onPressed: () => _delete(category),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
              );
            },
          ),
  );
}
