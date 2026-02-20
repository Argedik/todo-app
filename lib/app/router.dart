import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/main_shell.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/ai_rules/presentation/ai_rules_screen.dart';
import '../features/ai_rules/presentation/ai_rule_set_detail_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/messages/presentation/messages_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tasks/presentation/task_detail_screen.dart';
import '../features/activities/presentation/activity_detail_screen.dart';
import '../features/calendar/presentation/calendar_event_detail_screen.dart';
import '../features/messages/presentation/message_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/ai-rules',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiRulesScreen(),
            ),
          ),
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/messages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MessagesScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/task/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TaskDetailScreen(
          taskId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/activity/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ActivityDetailScreen(
          activityId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/ai-rule/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AiRuleSetDetailScreen(
          ruleSetId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/calendar-event/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CalendarEventDetailScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/message/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MessageDetailScreen(
          messageId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
