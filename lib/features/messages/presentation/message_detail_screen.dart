import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/models/generated_message_model.dart';
import '../../../shared/providers/providers.dart';

class MessageDetailScreen extends ConsumerWidget {
  final String messageId;

  const MessageDetailScreen({super.key, required this.messageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages =
        ref.watch(messagesStreamProvider).valueOrNull ?? [];
    final message =
        messages.where((m) => m.id == messageId).firstOrNull;

    if (message == null) {
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
                    onPressed: () => _toggleFavorite(ref, message),
                    icon: Icon(
                      message.isFavorite
                          ? Icons.star
                          : Icons.star_border,
                      color: message.isFavorite
                          ? AppColors.warning
                          : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _archive(context, ref, message),
                    icon: const Icon(Icons.archive_outlined),
                  ),
                  IconButton(
                    onPressed: () => _delete(context, ref),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message.title,
                style:
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
              const SizedBox(height: 8),
              Text(
                AppDateUtils.formatDateTime(message.createdAt),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(
                  message.content,
                  style: const TextStyle(fontSize: 15, height: 1.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: message.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kopyalandı!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Kopyala'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Share.share(message.content),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Paylaş'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _regenerateMessage(context, ref, message),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tekrar Üret'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Kısa Versiyon'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Uzun Versiyon'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref, GeneratedMessageModel message) {
    final uid = ref.read(currentUidProvider);
    if (uid != null) {
      ref.read(messageRepositoryProvider).toggleFavorite(uid, message);
    }
  }

  Future<void> _archive(BuildContext context, WidgetRef ref,
      GeneratedMessageModel message) async {
    final uid = ref.read(currentUidProvider);
    if (uid != null) {
      await ref
          .read(messageRepositoryProvider)
          .archiveMessage(uid, message.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _regenerateMessage(BuildContext context, WidgetRef ref,
      GeneratedMessageModel message) async {
    // TODO: Cloud Function ile tekrar üret
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Tekrar üretme özelliği Cloud Functions kurulumu ile aktif olacak')),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mesajı Sil'),
        content:
            const Text('Bu mesajı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) {
        await ref
            .read(messageRepositoryProvider)
            .deleteMessage(uid, messageId);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}
