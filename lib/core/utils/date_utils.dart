import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'tr_TR');
  static final DateFormat _dateTimeFormat =
      DateFormat('dd MMM yyyy HH:mm', 'tr_TR');
  static final DateFormat _dayMonth = DateFormat('dd MMM', 'tr_TR');

  static String formatDate(DateTime date) => _dateFormat.format(date.toLocal());
  static String formatTime(DateTime date) => _timeFormat.format(date.toLocal());
  static String formatDateTime(DateTime date) =>
      _dateTimeFormat.format(date.toLocal());
  static String formatDayMonth(DateTime date) =>
      _dayMonth.format(date.toLocal());

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return formatDate(date);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime combineDateAndTime(DateTime date, int hour, int minute) =>
      DateTime(date.year, date.month, date.day, hour, minute);

  static bool isPastDateTime(DateTime dateTime) =>
      dateTime.isBefore(DateTime.now());
}
