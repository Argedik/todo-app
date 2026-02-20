import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String section;
  final DateTime? reminderAt;
  final bool reminderEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int orderIndex;
  final String? categoryId;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.section = 'gorevlerim',
    this.reminderAt,
    this.reminderEnabled = false,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.orderIndex = 0,
    this.categoryId,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? section,
    DateTime? reminderAt,
    bool? reminderEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? orderIndex,
    String? categoryId,
    bool clearReminder = false,
    bool clearDescription = false,
    bool clearCompletedAt = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      section: section ?? this.section,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      reminderEnabled: clearReminder
          ? false
          : (reminderEnabled ?? this.reminderEnabled),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      orderIndex: orderIndex ?? this.orderIndex,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      isCompleted: data['isCompleted'] ?? false,
      section: data['section'] ?? 'gorevlerim',
      reminderAt: (data['reminderAt'] as Timestamp?)?.toDate(),
      reminderEnabled: data['reminderEnabled'] ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      orderIndex: data['orderIndex'] ?? 0,
      categoryId: data['categoryId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'section': section,
      'reminderAt':
          reminderAt != null ? Timestamp.fromDate(reminderAt!) : null,
      'reminderEnabled': reminderEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'orderIndex': orderIndex,
      'categoryId': categoryId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'section': section,
      'reminderAt': reminderAt?.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'orderIndex': orderIndex,
      'categoryId': categoryId,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      section: json['section'] ?? 'gorevlerim',
      reminderAt: json['reminderAt'] != null
          ? DateTime.parse(json['reminderAt'])
          : null,
      reminderEnabled: json['reminderEnabled'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      orderIndex: json['orderIndex'] ?? 0,
      categoryId: json['categoryId'],
    );
  }
}
