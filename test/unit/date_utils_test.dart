import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    test('isSameDay returns true for same day', () {
      final a = DateTime(2026, 2, 20, 10, 0);
      final b = DateTime(2026, 2, 20, 23, 59);
      expect(AppDateUtils.isSameDay(a, b), true);
    });

    test('isSameDay returns false for different days', () {
      final a = DateTime(2026, 2, 20);
      final b = DateTime(2026, 2, 21);
      expect(AppDateUtils.isSameDay(a, b), false);
    });

    test('combineDateAndTime creates correct DateTime', () {
      final date = DateTime(2026, 3, 15);
      final result = AppDateUtils.combineDateAndTime(date, 14, 30);
      expect(result, DateTime(2026, 3, 15, 14, 30));
    });

    test('isPastDateTime detects past dates', () {
      final past = DateTime(2020, 1, 1);
      expect(AppDateUtils.isPastDateTime(past), true);
    });

    test('isPastDateTime detects future dates', () {
      final future = DateTime(2030, 1, 1);
      expect(AppDateUtils.isPastDateTime(future), false);
    });
  });
}
