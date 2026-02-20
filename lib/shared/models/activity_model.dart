import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String title;
  final String? description;
  final DateTime activityAt;
  final DateTime? reminderAt;
  final bool reminderEnabled;
  final String? categoryId;
  final List<String> checklist;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ActivityModel({
    required this.id,
    required this.title,
    this.description,
    required this.activityAt,
    this.reminderAt,
    this.reminderEnabled = false,
    this.categoryId,
    this.checklist = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  ActivityModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? activityAt,
    DateTime? reminderAt,
    bool? reminderEnabled,
    String? categoryId,
    List<String>? checklist,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearReminder = false,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      activityAt: activityAt ?? this.activityAt,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      reminderEnabled: clearReminder
          ? false
          : (reminderEnabled ?? this.reminderEnabled),
      categoryId: categoryId ?? this.categoryId,
      checklist: checklist ?? this.checklist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      activityAt:
          (data['activityAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reminderAt: (data['reminderAt'] as Timestamp?)?.toDate(),
      reminderEnabled: data['reminderEnabled'] ?? false,
      categoryId: data['categoryId'],
      checklist: List<String>.from(data['checklist'] ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'activityAt': Timestamp.fromDate(activityAt),
      'reminderAt':
          reminderAt != null ? Timestamp.fromDate(reminderAt!) : null,
      'reminderEnabled': reminderEnabled,
      'categoryId': categoryId,
      'checklist': checklist,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'activityAt': activityAt.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'categoryId': categoryId,
      'checklist': checklist,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      activityAt: DateTime.parse(json['activityAt']),
      reminderAt: json['reminderAt'] != null
          ? DateTime.parse(json['reminderAt'])
          : null,
      reminderEnabled: json['reminderEnabled'] ?? false,
      categoryId: json['categoryId'],
      checklist: List<String>.from(json['checklist'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
