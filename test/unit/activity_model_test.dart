import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/shared/models/activity_model.dart';

void main() {
  group('ActivityModel', () {
    final now = DateTime(2026, 2, 20, 14, 30);

    test('toJson/fromJson roundtrip should preserve data', () {
      final activity = ActivityModel(
        id: 'act1',
        title: 'Toplantı',
        description: 'Haftalık toplantı',
        activityAt: now,
        reminderAt: now.subtract(const Duration(hours: 1)),
        reminderEnabled: true,
        categoryId: 'Toplantı',
        checklist: ['Gündem hazırla', 'Sunum yap'],
        createdAt: now,
        updatedAt: now,
      );

      final json = activity.toJson();
      final restored = ActivityModel.fromJson(json);

      expect(restored.id, activity.id);
      expect(restored.title, activity.title);
      expect(restored.description, activity.description);
      expect(restored.reminderEnabled, true);
      expect(restored.checklist.length, 2);
      expect(restored.categoryId, 'Toplantı');
    });

    test('copyWith clearReminder should reset reminder', () {
      final activity = ActivityModel(
        id: '1',
        title: 'Test',
        activityAt: now,
        reminderAt: now,
        reminderEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final cleared = activity.copyWith(clearReminder: true);

      expect(cleared.reminderAt, isNull);
      expect(cleared.reminderEnabled, false);
    });
  });
}
