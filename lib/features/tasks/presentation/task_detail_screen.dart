import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/models/task_model.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/widgets/reminder_date_time_picker_sheet.dart';
import 'add_task_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksStreamProvider).valueOrNull ?? [];
    final task = tasks.where((t) => t.id == taskId).firstOrNull;

    if (task == null) {
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
                    onPressed: () => _editTask(context, task),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => _deleteTask(context, ref, task),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildCheckbox(context, ref, task),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      task.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                    ),
                  ),
                ],
              ),
              if (task.description != null &&
                  task.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                ),
              ],
              const SizedBox(height: 32),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Oluşturulma',
                value: AppDateUtils.formatDateTime(task.createdAt),
              ),
              if (task.isCompleted && task.completedAt != null)
                _buildInfoRow(
                  context,
                  icon: Icons.check_circle,
                  label: 'Tamamlanma',
                  value: AppDateUtils.formatDateTime(task.completedAt!),
                  color: AppColors.success,
                ),
              const Divider(height: 32),
              _buildReminderSection(context, ref, task),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, WidgetRef ref, TaskModel task) {
    return GestureDetector(
      onTap: () {
        final uid = ref.read(currentUidProvider);
        if (uid != null) {
          ref.read(taskRepositoryProvider).toggleComplete(uid, task);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.isCompleted ? AppColors.success : Colors.transparent,
          border: Border.all(
            color: task.isCompleted ? AppColors.success : AppColors.textDisabled,
            width: 2,
          ),
        ),
        child: task.isCompleted
            ? const Icon(Icons.check, size: 20, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(
      BuildContext context, WidgetRef ref, TaskModel task) {
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
          onTap: () => _showReminderPicker(context, ref, task),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: task.reminderEnabled
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.reminderEnabled
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  task.reminderEnabled ? Icons.alarm_on : Icons.alarm,
                  color: task.reminderEnabled
                      ? AppColors.reminderActive
                      : AppColors.reminderInactive,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.reminderEnabled && task.reminderAt != null
                        ? AppDateUtils.formatDateTime(
                            task.reminderAt!.toLocal())
                        : 'Hatırlatma ekle',
                    style: TextStyle(
                      color: task.reminderEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showReminderPicker(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    final result = await ReminderDateTimePickerSheet.show(
      context,
      initialDateTime: task.reminderAt?.toLocal(),
      onRemove: () {
        final uid = ref.read(currentUidProvider);
        if (uid != null) {
          final updated = task.copyWith(
            clearReminder: true,
            updatedAt: DateTime.now(),
          );
          ref.read(taskRepositoryProvider).updateTask(uid, updated);
          NotificationService()
              .cancelNotification(NotificationService()
                  .generateNotificationId(task.id));
        }
      },
    );

    if (result != null) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) {
        final updated = task.copyWith(
          reminderAt: result.dateTime,
          reminderEnabled: true,
          updatedAt: DateTime.now(),
        );
        await ref.read(taskRepositoryProvider).updateTask(uid, updated);

        final notifService = NotificationService();
        await notifService.scheduleNotification(
          id: notifService.generateNotificationId(task.id),
          title: 'Görev Hatırlatma',
          body: task.title,
          scheduledAt: result.dateTime.toLocal(),
          payload: 'task:${task.id}',
        );
      }
    }
  }

  void _editTask(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(editTask: task),
    );
  }

  Future<void> _deleteTask(
      BuildContext context, WidgetRef ref, TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: const Text('Bu görevi silmek istediğinize emin misiniz?'),
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
        await ref.read(taskRepositoryProvider).deleteTask(uid, task.id);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}
