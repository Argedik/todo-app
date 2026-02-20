import 'package:cloud_firestore/cloud_firestore.dart';

class AiRuleSetModel {
  final String id;
  final String name;
  final String category;
  final String greetingStyle;
  final String tone;
  final String emojiPolicy;
  final List<String> fixedPhrases;
  final List<String> bannedWords;
  final String lengthTarget;
  final String? customInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiRuleSetModel({
    required this.id,
    required this.name,
    this.category = 'Genel',
    this.greetingStyle = '',
    this.tone = 'resmi',
    this.emojiPolicy = 'kapalı',
    this.fixedPhrases = const [],
    this.bannedWords = const [],
    this.lengthTarget = 'orta',
    this.customInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  static const List<String> categories = [
    'Genel',
    'Toplantı',
    'Duyuru',
    'Hatırlatma',
    'Ramazan',
    'Resmi',
    'Samimi',
    'Kutlama',
    'Davet',
  ];

  static const List<String> tones = [
    'resmi',
    'samimi',
    'kısa',
    'uzun',
    'profesyonel',
    'arkadaşça',
  ];

  static const List<String> emojiPolicies = [
    'açık',
    'kapalı',
    'minimum',
    'maksimum',
  ];

  static const List<String> lengthTargets = [
    'kısa',
    'orta',
    'uzun',
  ];

  AiRuleSetModel copyWith({
    String? id,
    String? name,
    String? category,
    String? greetingStyle,
    String? tone,
    String? emojiPolicy,
    List<String>? fixedPhrases,
    List<String>? bannedWords,
    String? lengthTarget,
    String? customInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiRuleSetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      greetingStyle: greetingStyle ?? this.greetingStyle,
      tone: tone ?? this.tone,
      emojiPolicy: emojiPolicy ?? this.emojiPolicy,
      fixedPhrases: fixedPhrases ?? this.fixedPhrases,
      bannedWords: bannedWords ?? this.bannedWords,
      lengthTarget: lengthTarget ?? this.lengthTarget,
      customInstructions: customInstructions ?? this.customInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AiRuleSetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AiRuleSetModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Genel',
      greetingStyle: data['greetingStyle'] ?? '',
      tone: data['tone'] ?? 'resmi',
      emojiPolicy: data['emojiPolicy'] ?? 'kapalı',
      fixedPhrases: List<String>.from(data['fixedPhrases'] ?? []),
      bannedWords: List<String>.from(data['bannedWords'] ?? []),
      lengthTarget: data['lengthTarget'] ?? 'orta',
      customInstructions: data['customInstructions'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'greetingStyle': greetingStyle,
      'tone': tone,
      'emojiPolicy': emojiPolicy,
      'fixedPhrases': fixedPhrases,
      'bannedWords': bannedWords,
      'lengthTarget': lengthTarget,
      'customInstructions': customInstructions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'greetingStyle': greetingStyle,
      'tone': tone,
      'emojiPolicy': emojiPolicy,
      'fixedPhrases': fixedPhrases,
      'bannedWords': bannedWords,
      'lengthTarget': lengthTarget,
      'customInstructions': customInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AiRuleSetModel.fromJson(Map<String, dynamic> json) {
    return AiRuleSetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Genel',
      greetingStyle: json['greetingStyle'] ?? '',
      tone: json['tone'] ?? 'resmi',
      emojiPolicy: json['emojiPolicy'] ?? 'kapalı',
      fixedPhrases: List<String>.from(json['fixedPhrases'] ?? []),
      bannedWords: List<String>.from(json['bannedWords'] ?? []),
      lengthTarget: json['lengthTarget'] ?? 'orta',
      customInstructions: json['customInstructions'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
