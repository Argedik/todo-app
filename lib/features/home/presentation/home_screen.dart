import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../tasks/presentation/add_task_sheet.dart';
import '../../activities/presentation/add_activity_sheet.dart';

enum HomeSection { gorevlerim, aktiviteler }

final homeSectionProvider =
    StateProvider<HomeSection>((ref) => HomeSection.gorevlerim);

final taskSubSectionProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(homeSectionProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            _buildSectionTabs(context, ref, section),
            Expanded(
              child: section == HomeSection.gorevlerim
                  ? const _TasksSection()
                  : const _ActivitiesSection(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () {
          if (section == HomeSection.gorevlerim) {
            _showAddTaskSheet(context);
          } else {
            _showAddActivitySheet(context);
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (user?.photoURL != null)
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user!.photoURL!),
            )
          else
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merhaba, ${user?.displayName?.split(' ').first ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  AppDateUtils.formatDate(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(
      BuildContext context, WidgetRef ref, HomeSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _SectionTab(
            label: 'Görevlerim',
            isSelected: section == HomeSection.gorevlerim,
            onTap: () => ref.read(homeSectionProvider.notifier).state =
                HomeSection.gorevlerim,
          ),
          const SizedBox(width: 12),
          _SectionTab(
            label: 'Aktiviteler',
            isSelected: section == HomeSection.aktiviteler,
            onTap: () => ref.read(homeSectionProvider.notifier).state =
                HomeSection.aktiviteler,
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }

  void _showAddActivitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddActivitySheet(),
    );
  }
}

class _SectionTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textDisabled,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TasksSection extends ConsumerWidget {
  const _TasksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subSection = ref.watch(taskSubSectionProvider);
    final pending = ref.watch(pendingTasksProvider);
    final completed = ref.watch(completedTasksProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _SubSectionChip(
                label: 'Yapacaklarım (${pending.length})',
                isSelected: subSection == 0,
                onTap: () =>
                    ref.read(taskSubSectionProvider.notifier).state = 0,
              ),
              const SizedBox(width: 8),
              _SubSectionChip(
                label: 'Yaptıklarım (${completed.length})',
                isSelected: subSection == 1,
                onTap: () =>
                    ref.read(taskSubSectionProvider.notifier).state = 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: subSection == 0
              ? _buildTaskList(context, ref, pending)
              : _buildTaskList(context, ref, completed),
        ),
      ],
    );
  }

  Widget _buildTaskList(
      BuildContext context, WidgetRef ref, List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'Henüz görev yok',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => context.push('/task/${task.id}'),
          onToggle: () {
            final uid = ref.read(currentUidProvider);
            if (uid != null) {
              ref.read(taskRepositoryProvider).toggleComplete(uid, task);
            }
          },
          onReminderTap: () => _showReminderPicker(context, ref, task),
        );
      },
    );
  }

  void _showReminderPicker(
      BuildContext context, WidgetRef ref, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReminderPickerEntryPoint(task: task),
    );
  }
}

class _ReminderPickerEntryPoint extends ConsumerWidget {
  final TaskModel task;

  const _ReminderPickerEntryPoint({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(); // ReminderDateTimePickerSheet burada kullanılacak
  }
}

class _SubSectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubSectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        backgroundColor:
            isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.textDisabled,
        ),
      ),
    );
  }
}

class _ActivitiesSection extends ConsumerWidget {
  const _ActivitiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesStreamProvider).valueOrNull ?? [];

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined,
                size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'Henüz aktivite yok',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ActivityCard(
          activity: activity,
          onTap: () => context.push('/activity/${activity.id}'),
        );
      },
    );
  }
}
