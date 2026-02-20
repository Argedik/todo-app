abstract class AppConstants {
  static const String appName = 'Notlarım';
  static const String driveBackupFolder = 'Notlarim_Backups';
  static const String defaultLanguage = 'tr';

  static const Duration defaultReminderBefore = Duration(hours: 1);

  static const int maxMessageLength = 2000;
  static const int minMessageLength = 50;
}

abstract class FirestorePaths {
  static String userDoc(String uid) => 'users/$uid';
  static String tasks(String uid) => 'users/$uid/tasks';
  static String task(String uid, String taskId) => 'users/$uid/tasks/$taskId';
  static String activities(String uid) => 'users/$uid/activities';
  static String activity(String uid, String id) => 'users/$uid/activities/$id';
  static String notes(String uid) => 'users/$uid/notes';
  static String aiRuleSets(String uid) => 'users/$uid/aiRuleSets';
  static String aiRuleSet(String uid, String id) =>
      'users/$uid/aiRuleSets/$id';
  static String calendarEvents(String uid) => 'users/$uid/calendarEvents';
  static String calendarEvent(String uid, String id) =>
      'users/$uid/calendarEvents/$id';
  static String generatedMessages(String uid) =>
      'users/$uid/generatedMessages';
  static String generatedMessage(String uid, String id) =>
      'users/$uid/generatedMessages/$id';
  static String syncJobs(String uid) => 'users/$uid/syncJobs';
}
