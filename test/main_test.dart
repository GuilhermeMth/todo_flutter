import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/main.dart';

void main() {
  test('Task serializes and restores all required fields', () {
    final createdAt = DateTime.utc(2026, 9, 25, 12, 30);
    final dueDateTime = DateTime.utc(2026, 9, 26, 9);
    final task = Task(
      id: 7,
      title: 'Revisar projeto',
      description: 'Executar a validação final',
      completed: true,
      createdAt: createdAt,
      dueDateTime: dueDateTime,
      categoryId: 3,
    );

    final restored = Task.fromMap(task.toMap());

    expect(restored.id, 7);
    expect(restored.title, 'Revisar projeto');
    expect(restored.description, 'Executar a validação final');
    expect(restored.completed, isTrue);
    expect(restored.createdAt, createdAt);
    expect(restored.dueDateTime, dueDateTime);
    expect(restored.categoryId, 3);
  });

  test('Task map omits the id when creating a new task', () {
    final task = Task(
      id: null,
      title: 'Nova tarefa',
      description: '',
      completed: false,
      createdAt: DateTime.utc(2026, 9, 25),
    );

    expect(task.toMap(), isNot(contains('id')));
    expect(task.toMap()['completed'], 0);
    expect(task.toMap()['due_date_time'], isNull);
    expect(task.toMap()['category_id'], isNull);
  });

  test('Category serializes and restores its identity', () {
    const category = Category(id: 4, name: 'Trabalho');

    expect(Category.fromMap(category.toMap()).id, 4);
    expect(Category.fromMap(category.toMap()).name, 'Trabalho');
  });
}
