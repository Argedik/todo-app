import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/shared/models/ai_rule_set_model.dart';

void main() {
  group('AiRuleSetModel', () {
    final now = DateTime(2026, 2, 20);

    test('toJson/fromJson roundtrip', () {
      final ruleSet = AiRuleSetModel(
        id: 'rs1',
        name: 'Toplantı resmi',
        category: 'Toplantı',
        greetingStyle: 'Sayın meslektaşlarım',
        tone: 'resmi',
        emojiPolicy: 'kapalı',
        fixedPhrases: ['İyi çalışmalar', 'Saygılarımla'],
        bannedWords: ['argo'],
        lengthTarget: 'orta',
        customInstructions: 'Her zaman kibar ol',
        createdAt: now,
        updatedAt: now,
      );

      final json = ruleSet.toJson();
      final restored = AiRuleSetModel.fromJson(json);

      expect(restored.name, 'Toplantı resmi');
      expect(restored.fixedPhrases, hasLength(2));
      expect(restored.bannedWords, contains('argo'));
      expect(restored.customInstructions, 'Her zaman kibar ol');
    });

    test('categories list should not be empty', () {
      expect(AiRuleSetModel.categories, isNotEmpty);
      expect(AiRuleSetModel.categories, contains('Toplantı'));
    });

    test('tones list should not be empty', () {
      expect(AiRuleSetModel.tones, isNotEmpty);
      expect(AiRuleSetModel.tones, contains('resmi'));
      expect(AiRuleSetModel.tones, contains('samimi'));
    });
  });
}
