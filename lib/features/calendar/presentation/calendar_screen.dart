import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/providers.dart';
import 'add_calendar_event_sheet.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedCalendarDayProvider);
    final events = ref.watch(calendarEventsStreamProvider).valueOrNull ?? [];
    final tasks = ref.watch(tasksStreamProvider).valueOrNull ?? [];
    final activities =
        ref.watch(activitiesStreamProvider).valueOrNull ?? [];

    final dayEvents = events
        .where((e) => AppDateUtils.isSameDay(e.startAt, selectedDay))
        .toList();

    final dayTasks = tasks
        .where(
            (t) => t.reminderAt != null && AppDateUtils.isSameDay(t.reminderAt!, selectedDay))
        .toList();

    final dayActivities = activities
        .where((a) => AppDateUtils.isSameDay(a.activityAt, selectedDay))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Takvim',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(selectedCalendarDayProvider.notifier)
                        .state = DateTime.now(),
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Bugün'),
                  ),
                ],
              ),
            ),
            TableCalendar(
              locale: 'tr_TR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDay,
              selectedDayPredicate: (day) =>
                  AppDateUtils.isSameDay(day, selectedDay),
              onDaySelected: (selected, focused) {
                ref.read(selectedCalendarDayProvider.notifier).state =
                    selected;
              },
              eventLoader: (day) {
                final count = events
                    .where((e) => AppDateUtils.isSameDay(e.startAt, day))
                    .length;
                return List.generate(count, (_) => null);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                markerSize: 6,
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarFormat: CalendarFormat.month,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    AppDateUtils.formatDate(selectedDay),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${dayEvents.length + dayTasks.length + dayActivities.length} öğe',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...dayEvents.map((e) => _EventTile(
                        title: e.title,
                        subtitle:
                            '${AppDateUtils.formatTime(e.startAt)} - ${AppDateUtils.formatTime(e.endAt)}',
                        icon: Icons.event,
                        color: AppColors.primary,
                        onTap: () =>
                            context.push('/calendar-event/${e.id}'),
                      )),
                  ...dayTasks.map((t) => _EventTile(
                        title: t.title,
                        subtitle: 'Görev hatırlatma',
                        icon: Icons.task_alt,
                        color: AppColors.success,
                        onTap: () => context.push('/task/${t.id}'),
                      )),
                  ...dayActivities.map((a) => _EventTile(
                        title: a.title,
                        subtitle: AppDateUtils.formatTime(a.activityAt),
                        icon: Icons.local_activity,
                        color: AppColors.accent,
                        onTap: () =>
                            context.push('/activity/${a.id}'),
                      )),
                  if (dayEvents.isEmpty &&
                      dayTasks.isEmpty &&
                      dayActivities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Bu günde etkinlik yok',
                          style:
                              TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar_fab',
        onPressed: () => _showAddEvent(context, selectedDay),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEvent(BuildContext context, DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCalendarEventSheet(initialDate: day),
    );
  }
}

class _EventTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EventTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing:
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
