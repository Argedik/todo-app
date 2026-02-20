import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/ai_rule_set_model.dart';
import '../../../shared/providers/providers.dart';

class AiRuleSetFormSheet extends ConsumerStatefulWidget {
  final AiRuleSetModel? editRuleSet;

  const AiRuleSetFormSheet({super.key, this.editRuleSet});

  @override
  ConsumerState<AiRuleSetFormSheet> createState() =>
      _AiRuleSetFormSheetState();
}

class _AiRuleSetFormSheetState extends ConsumerState<AiRuleSetFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _greetingController;
  late TextEditingController _customController;
  late TextEditingController _fixedPhrasesController;
  late TextEditingController _bannedWordsController;
  String _category = 'Genel';
  String _tone = 'resmi';
  String _emojiPolicy = 'kapalı';
  String _lengthTarget = 'orta';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.editRuleSet;
    _nameController = TextEditingController(text: r?.name ?? '');
    _greetingController = TextEditingController(text: r?.greetingStyle ?? '');
    _customController =
        TextEditingController(text: r?.customInstructions ?? '');
    _fixedPhrasesController =
        TextEditingController(text: r?.fixedPhrases.join(', ') ?? '');
    _bannedWordsController =
        TextEditingController(text: r?.bannedWords.join(', ') ?? '');
    if (r != null) {
      _category = r.category;
      _tone = r.tone;
      _emojiPolicy = r.emojiPolicy;
      _lengthTarget = r.lengthTarget;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _greetingController.dispose();
    _customController.dispose();
    _fixedPhrasesController.dispose();
    _bannedWordsController.dispose();
    super.dispose();
  }

  List<String> _parseCommaSeparated(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    final ruleSet = AiRuleSetModel(
      id: widget.editRuleSet?.id ?? '',
      name: name,
      category: _category,
      greetingStyle: _greetingController.text.trim(),
      tone: _tone,
      emojiPolicy: _emojiPolicy,
      fixedPhrases: _parseCommaSeparated(_fixedPhrasesController.text),
      bannedWords: _parseCommaSeparated(_bannedWordsController.text),
      lengthTarget: _lengthTarget,
      customInstructions: _customController.text.trim().isNotEmpty
          ? _customController.text.trim()
          : null,
      createdAt: widget.editRuleSet?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.editRuleSet != null) {
        await ref
            .read(aiRuleSetRepositoryProvider)
            .updateRuleSet(uid, ruleSet);
      } else {
        await ref
            .read(aiRuleSetRepositoryProvider)
            .addRuleSet(uid, ruleSet);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editRuleSet != null;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Kural Setini Düzenle' : 'Yeni Kural Seti',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Kural adı',
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: AiRuleSetModel.categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _greetingController,
                    decoration: const InputDecoration(
                      labelText: 'Hitap şekli',
                      hintText: 'Örn: Sayın meslektaşlarım',
                      prefixIcon: Icon(Icons.waving_hand),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _tone,
                    decoration: const InputDecoration(
                      labelText: 'Üslup',
                      prefixIcon: Icon(Icons.record_voice_over),
                    ),
                    items: AiRuleSetModel.tones
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _tone = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _emojiPolicy,
                    decoration: const InputDecoration(
                      labelText: 'Emoji kullanımı',
                      prefixIcon: Icon(Icons.emoji_emotions),
                    ),
                    items: AiRuleSetModel.emojiPolicies
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _emojiPolicy = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _lengthTarget,
                    decoration: const InputDecoration(
                      labelText: 'Mesaj uzunluğu',
                      prefixIcon: Icon(Icons.short_text),
                    ),
                    items: AiRuleSetModel.lengthTargets
                        .map((l) =>
                            DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() => _lengthTarget = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fixedPhrasesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Sabit cümleler (virgülle ayırın)',
                      prefixIcon: Icon(Icons.format_quote),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bannedWordsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Yasak kelimeler (virgülle ayırın)',
                      prefixIcon: Icon(Icons.block),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Özel notlar',
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEditing ? 'Güncelle' : 'Oluştur'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
