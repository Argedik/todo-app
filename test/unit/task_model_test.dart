import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/shared/models/task_model.dart';

void main() {
  group('TaskModel', () {
    final now = DateTime(2026, 2, 20, 10, 0);

    test('copyWith should update only specified fields', () {
      final task = TaskModel(
        id: '1',
        title: 'Test görev',
        createdAt: now,
        updatedAt: now,
      );

      final updated = task.copyWith(title: 'Güncellenmiş görev');

      expect(updated.title, 'Güncellenmiş görev');
      expect(updated.id, '1');
      expect(updated.isCompleted, false);
    });

    test('copyWith with isCompleted should toggle correctly', () {
      final task = TaskModel(
        id: '1',
        title: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      final completed = task.copyWith(
        isCompleted: true,
        completedAt: now,
      );

      expect(completed.isCompleted, true);
      expect(completed.completedAt, now);
    });

    test('copyWith clearReminder should reset reminder fields', () {
      final task = TaskModel(
        id: '1',
        title: 'Test',
        reminderAt: now,
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final cleared = task.copyWith(clearReminder: true);

      expect(cleared.reminderAt, isNull);
      expect(cleared.reminderEnabled, false);
    });

    test('toJson/fromJson roundtrip should preserve data', () {
      final task = TaskModel(
        id: 'abc123',
        title: 'Test görev',
        description: 'Açıklama',
        isCompleted: false,
        section: 'gorevlerim',
        reminderAt: now.toUtc(),
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
        orderIndex: 5,
      );

      final json = task.toJson();
      final restored = TaskModel.fromJson(json);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.isCompleted, task.isCompleted);
      expect(restored.reminderEnabled, task.reminderEnabled);
      expect(restored.orderIndex, 5);
    });

    test('default values should be correct', () {
      final task = TaskModel(
        id: '1',
        title: 'Varsayılan',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isCompleted, false);
      expect(task.section, 'gorevlerim');
      expect(task.reminderEnabled, false);
      expect(task.reminderAt, isNull);
      expect(task.description, isNull);
      expect(task.completedAt, isNull);
      expect(task.orderIndex, 0);
    });
  });
}
