import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderRule {
  final String type;
  final int value;
  final String unit;

  const ReminderRule({
    this.type = 'before',
    required this.value,
    required this.unit,
  });

  factory ReminderRule.fromMap(Map<String, dynamic> map) {
    return ReminderRule(
      type: map['type'] ?? 'before',
      value: map['value'] ?? 0,
      unit: map['unit'] ?? 'hour',
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'value': value,
        'unit': unit,
      };

  Duration toDuration() {
    switch (unit) {
      case 'minute':
        return Duration(minutes: value);
      case 'hour':
        return Duration(hours: value);
      case 'day':
        return Duration(days: value);
      default:
        return Duration(hours: value);
    }
  }

  String toReadableString() {
    switch (unit) {
      case 'minute':
        return '$value dakika önce';
      case 'hour':
        return '$value saat önce';
      case 'day':
        return '$value gün önce';
      default:
        return '$value $unit önce';
    }
  }
}

class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final List<ReminderRule> reminderRules;
  final String? linkedRuleSetId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startAt,
    required this.endAt,
    this.reminderRules = const [],
    this.linkedRuleSetId,
    required this.createdAt,
    required this.updatedAt,
  });

  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    List<ReminderRule>? reminderRules,
    String? linkedRuleSetId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLinkedRuleSet = false,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      reminderRules: reminderRules ?? this.reminderRules,
      linkedRuleSetId: clearLinkedRuleSet
          ? null
          : (linkedRuleSetId ?? this.linkedRuleSetId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CalendarEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      startAt: (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endAt: (data['endAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reminderRules: (data['reminderRules'] as List<dynamic>?)
              ?.map((e) => ReminderRule.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      linkedRuleSetId: data['linkedRuleSetId'],
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
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'reminderRules': reminderRules.map((r) => r.toMap()).toList(),
      'linkedRuleSetId': linkedRuleSetId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'reminderRules': reminderRules.map((r) => r.toMap()).toList(),
      'linkedRuleSetId': linkedRuleSetId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
