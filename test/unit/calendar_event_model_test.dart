import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/shared/models/calendar_event_model.dart';

void main() {
  group('ReminderRule', () {
    test('toDuration returns correct Duration', () {
      expect(
        const ReminderRule(value: 30, unit: 'minute').toDuration(),
        const Duration(minutes: 30),
      );
      expect(
        const ReminderRule(value: 2, unit: 'hour').toDuration(),
        const Duration(hours: 2),
      );
      expect(
        const ReminderRule(value: 1, unit: 'day').toDuration(),
        const Duration(days: 1),
      );
    });

    test('toReadableString returns Turkish text', () {
      expect(
        const ReminderRule(value: 30, unit: 'minute').toReadableString(),
        '30 dakika önce',
      );
      expect(
        const ReminderRule(value: 1, unit: 'day').toReadableString(),
        '1 gün önce',
      );
    });
  });

  group('CalendarEventModel', () {
    final now = DateTime(2026, 3, 1, 9, 0);

    test('toJson preserves all fields', () {
      final event = CalendarEventModel(
        id: 'ev1',
        title: 'Haftalık toplantı',
        description: 'Medya birimi',
        startAt: now,
        endAt: now.add(const Duration(hours: 1)),
        reminderRules: [
          const ReminderRule(value: 1, unit: 'day'),
          const ReminderRule(value: 2, unit: 'hour'),
        ],
        linkedRuleSetId: 'rs1',
        createdAt: now,
        updatedAt: now,
      );

      final json = event.toJson();

      expect(json['title'], 'Haftalık toplantı');
      expect(json['reminderRules'], hasLength(2));
      expect(json['linkedRuleSetId'], 'rs1');
    });
  });
}
