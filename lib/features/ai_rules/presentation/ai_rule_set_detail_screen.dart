import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/ai_rule_set_model.dart';
import '../../../shared/providers/providers.dart';
import 'ai_rule_set_form_sheet.dart';

class AiRuleSetDetailScreen extends ConsumerWidget {
  final String ruleSetId;

  const AiRuleSetDetailScreen({super.key, required this.ruleSetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleSets = ref.watch(aiRuleSetsStreamProvider).valueOrNull ?? [];
    final ruleSet = ruleSets.where((r) => r.id == ruleSetId).firstOrNull;

    if (ruleSet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _edit(context, ruleSet),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => _delete(context, ref),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                ruleSet.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildChipRow(ruleSet),
              const SizedBox(height: 24),
              _buildDetail(context, 'Hitap şekli', ruleSet.greetingStyle),
              _buildDetail(context, 'Üslup', ruleSet.tone),
              _buildDetail(context, 'Emoji', ruleSet.emojiPolicy),
              _buildDetail(context, 'Uzunluk', ruleSet.lengthTarget),
              if (ruleSet.fixedPhrases.isNotEmpty)
                _buildDetail(
                    context, 'Sabit cümleler', ruleSet.fixedPhrases.join(', ')),
              if (ruleSet.bannedWords.isNotEmpty)
                _buildDetail(
                    context, 'Yasak kelimeler', ruleSet.bannedWords.join(', ')),
              if (ruleSet.customInstructions != null)
                _buildDetail(
                    context, 'Özel notlar', ruleSet.customInstructions!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipRow(AiRuleSetModel ruleSet) {
    return Wrap(
      spacing: 8,
      children: [
        Chip(
          label: Text(ruleSet.category, style: const TextStyle(fontSize: 12)),
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  void _edit(BuildContext context, AiRuleSetModel ruleSet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiRuleSetFormSheet(editRuleSet: ruleSet),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kural Setini Sil'),
        content: const Text('Bu kural setini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) {
        await ref
            .read(aiRuleSetRepositoryProvider)
            .deleteRuleSet(uid, ruleSetId);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}
