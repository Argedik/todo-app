import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsModel {
  final String themeMode;
  final String language;
  final bool notificationsEnabled;
  final DateTime? lastSyncAt;
  final DateTime? lastBackupAt;

  const UserSettingsModel({
    this.themeMode = 'system',
    this.language = 'tr',
    this.notificationsEnabled = true,
    this.lastSyncAt,
    this.lastBackupAt,
  });

  UserSettingsModel copyWith({
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    DateTime? lastSyncAt,
    DateTime? lastBackupAt,
  }) {
    return UserSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    );
  }

  factory UserSettingsModel.fromFirestore(Map<String, dynamic> data) {
    return UserSettingsModel(
      themeMode: data['themeMode'] ?? 'system',
      language: data['language'] ?? 'tr',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      lastSyncAt: (data['lastSyncAt'] as Timestamp?)?.toDate(),
      lastBackupAt: (data['lastBackupAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'themeMode': themeMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'lastSyncAt':
          lastSyncAt != null ? Timestamp.fromDate(lastSyncAt!) : null,
      'lastBackupAt':
          lastBackupAt != null ? Timestamp.fromDate(lastBackupAt!) : null,
    };
  }
}
