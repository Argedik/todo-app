import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/tasks/data/task_repository.dart';
import '../../features/activities/data/activity_repository.dart';
import '../../features/ai_rules/data/ai_rule_set_repository.dart';
import '../../features/calendar/data/calendar_event_repository.dart';
import '../../features/messages/data/message_repository.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../shared/models/models.dart';

// --- Repository Providers ---
final authRepositoryProvider = Provider((ref) => AuthRepository());
final taskRepositoryProvider = Provider((ref) => TaskRepository());
final activityRepositoryProvider = Provider((ref) => ActivityRepository());
final aiRuleSetRepositoryProvider = Provider((ref) => AiRuleSetRepository());
final calendarEventRepositoryProvider =
    Provider((ref) => CalendarEventRepository());
final messageRepositoryProvider = Provider((ref) => MessageRepository());
final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

// --- Auth State ---
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

// --- Task Providers ---
final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(taskRepositoryProvider).watchTasks(uid);
});

final pendingTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).valueOrNull ?? [];
  return tasks.where((t) => !t.isCompleted).toList();
});

final completedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).valueOrNull ?? [];
  return tasks.where((t) => t.isCompleted).toList();
});

// --- Activity Providers ---
final activitiesStreamProvider = StreamProvider<List<ActivityModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(activityRepositoryProvider).watchActivities(uid);
});

// --- AI Rule Set Providers ---
final aiRuleSetsStreamProvider = StreamProvider<List<AiRuleSetModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(aiRuleSetRepositoryProvider).watchRuleSets(uid);
});

// --- Calendar Event Providers ---
final calendarEventsStreamProvider =
    StreamProvider<List<CalendarEventModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(calendarEventRepositoryProvider).watchEvents(uid);
});

final selectedCalendarDayProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// --- Message Providers ---
final messagesStreamProvider =
    StreamProvider<List<GeneratedMessageModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(messageRepositoryProvider).watchMessages(uid);
});

// --- Settings Providers ---
final settingsStreamProvider = StreamProvider<UserSettingsModel>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const UserSettingsModel());
  return ref.watch(settingsRepositoryProvider).watchSettings(uid);
});

final themeModeProvider = Provider<String>((ref) {
  return ref.watch(settingsStreamProvider).valueOrNull?.themeMode ?? 'system';
});

// --- Navigation State ---
final bottomNavIndexProvider = StateProvider<int>((ref) => 2);
