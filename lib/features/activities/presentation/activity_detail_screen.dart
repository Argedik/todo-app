import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/models/activity_model.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/widgets/reminder_date_time_picker_sheet.dart';
import 'add_activity_sheet.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities =
        ref.watch(activitiesStreamProvider).valueOrNull ?? [];
    final activity =
        activities.where((a) => a.id == activityId).firstOrNull;

    if (activity == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _editActivity(context, activity),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () =>
                        _deleteActivity(context, ref, activity),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                activity.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (activity.categoryId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity.categoryId!,
                    style: TextStyle(color: AppColors.accent, fontSize: 13),
                  ),
                ),
              ],
              if (activity.description != null &&
                  activity.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  activity.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                ),
              ],
              const SizedBox(height: 32),
              _buildInfoRow(
                context,
                icon: Icons.event,
                label: 'Tarih/Saat',
                value: AppDateUtils.formatDateTime(activity.activityAt),
              ),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Oluşturulma',
                value: AppDateUtils.formatDateTime(activity.createdAt),
              ),
              const Divider(height: 32),
              _buildReminderSection(context, ref, activity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildReminderSection(
      BuildContext context, WidgetRef ref, ActivityModel activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hatırlatma',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showReminderPicker(context, ref, activity),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activity.reminderEnabled
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: activity.reminderEnabled
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  activity.reminderEnabled ? Icons.alarm_on : Icons.alarm,
                  color: activity.reminderEnabled
                      ? AppColors.reminderActive
                      : AppColors.reminderInactive,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity.reminderEnabled && activity.reminderAt != null
                        ? AppDateUtils.formatDateTime(
                            activity.reminderAt!.toLocal())
                        : 'Hatırlatma ekle',
                    style: TextStyle(
                      color: activity.reminderEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showReminderPicker(
      BuildContext context, WidgetRef ref, ActivityModel activity) async {
    final result = await ReminderDateTimePickerSheet.show(
      context,
      initialDateTime: activity.reminderAt?.toLocal(),
      onRemove: () {
        final uid = ref.read(currentUidProvider);
        if (uid != null) {
          final updated = activity.copyWith(
            clearReminder: true,
            updatedAt: DateTime.now(),
          );
          ref.read(activityRepositoryProvider).updateActivity(uid, updated);
          NotificationService().cancelNotification(
              NotificationService().generateNotificationId(activity.id));
        }
      },
    );

    if (result != null) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) {
        final updated = activity.copyWith(
          reminderAt: result.dateTime,
          reminderEnabled: true,
          updatedAt: DateTime.now(),
        );
        await ref
            .read(activityRepositoryProvider)
            .updateActivity(uid, updated);

        final notifService = NotificationService();
        await notifService.scheduleNotification(
          id: notifService.generateNotificationId(activity.id),
          title: 'Aktivite Hatırlatma',
          body: activity.title,
          scheduledAt: result.dateTime.toLocal(),
          payload: 'activity:${activity.id}',
        );
      }
    }
  }

  void _editActivity(BuildContext context, ActivityModel activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddActivitySheet(editActivity: activity),
    );
  }

  Future<void> _deleteActivity(
      BuildContext context, WidgetRef ref, ActivityModel activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aktiviteyi Sil'),
        content:
            const Text('Bu aktiviteyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) {
        await ref
            .read(activityRepositoryProvider)
            .deleteActivity(uid, activity.id);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}
