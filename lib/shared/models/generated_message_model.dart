import 'package:cloud_firestore/cloud_firestore.dart';

class GeneratedMessageModel {
  final String id;
  final String title;
  final String content;
  final String? sourceEventId;
  final String? ruleSetId;
  final bool isFavorite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GeneratedMessageModel({
    required this.id,
    required this.title,
    required this.content,
    this.sourceEventId,
    this.ruleSetId,
    this.isFavorite = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  GeneratedMessageModel copyWith({
    String? id,
    String? title,
    String? content,
    String? sourceEventId,
    String? ruleSetId,
    bool? isFavorite,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeneratedMessageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      ruleSetId: ruleSetId ?? this.ruleSetId,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GeneratedMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GeneratedMessageModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      sourceEventId: data['sourceEventId'],
      ruleSetId: data['ruleSetId'],
      isFavorite: data['isFavorite'] ?? false,
      isArchived: data['isArchived'] ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'sourceEventId': sourceEventId,
      'ruleSetId': ruleSetId,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'sourceEventId': sourceEventId,
      'ruleSetId': ruleSetId,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GeneratedMessageModel.fromJson(Map<String, dynamic> json) {
    return GeneratedMessageModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sourceEventId: json['sourceEventId'],
      ruleSetId: json['ruleSetId'],
      isFavorite: json['isFavorite'] ?? false,
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
