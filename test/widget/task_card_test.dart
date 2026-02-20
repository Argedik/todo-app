import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/shared/models/task_model.dart';
import 'package:todo_app/shared/widgets/task_card.dart';

void main() {
  group('TaskCard Widget', () {
    final now = DateTime(2026, 2, 20);

    Widget buildTestWidget(TaskModel task) {
      return MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onTap: () {},
            onToggle: () {},
            onReminderTap: () {},
          ),
        ),
      );
    }

    testWidgets('displays task title', (tester) async {
      final task = TaskModel(
        id: '1',
        title: 'Test Görevi',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestWidget(task));

      expect(find.text('Test Görevi'), findsOneWidget);
    });

    testWidgets('displays description when present', (tester) async {
      final task = TaskModel(
        id: '1',
        title: 'Görev',
        description: 'Açıklama metni',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestWidget(task));

      expect(find.text('Açıklama metni'), findsOneWidget);
    });

    testWidgets('shows alarm_on icon when reminder enabled', (tester) async {
      final task = TaskModel(
        id: '1',
        title: 'Alarm test',
        reminderAt: now.add(const Duration(hours: 1)),
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestWidget(task));

      expect(find.byIcon(Icons.alarm_on), findsOneWidget);
    });

    testWidgets('shows alarm icon when reminder disabled', (tester) async {
      final task = TaskModel(
        id: '1',
        title: 'No alarm',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestWidget(task));

      expect(find.byIcon(Icons.alarm), findsOneWidget);
    });

    testWidgets('checkbox shows check icon when completed', (tester) async {
      final task = TaskModel(
        id: '1',
        title: 'Done',
        isCompleted: true,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestWidget(task));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
