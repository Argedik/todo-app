import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/models/generated_message_model.dart';
import '../../../shared/providers/providers.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Mesajlar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'AI tarafından üretilen mesajlarınız',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: messages.when(
                data: (msgs) {
                  if (msgs.isEmpty) return _buildEmptyState();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) => _MessageCard(
                      message: msgs[index],
                      onTap: () =>
                          context.push('/message/${msgs[index].id}'),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Hata: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            'Henüz mesaj yok',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Takvim etkinliklerinden mesaj üretebilirsiniz',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends ConsumerWidget {
  final GeneratedMessageModel message;
  final VoidCallback onTap;

  const _MessageCard({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (message.isFavorite)
                    Icon(Icons.star, color: AppColors.warning, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    AppDateUtils.timeAgo(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const Spacer(),
                  _iconButton(
                    Icons.copy,
                    () {
                      Clipboard.setData(
                          ClipboardData(text: message.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Kopyalandı!'),
                            duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                  _iconButton(
                    Icons.share,
                    () => Share.share(message.content),
                  ),
                  _iconButton(
                    message.isFavorite ? Icons.star : Icons.star_border,
                    () {
                      final uid = ref.read(currentUidProvider);
                      if (uid != null) {
                        ref
                            .read(messageRepositoryProvider)
                            .toggleFavorite(uid, message);
                      }
                    },
                    color: message.isFavorite ? AppColors.warning : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            size: 18, color: color ?? AppColors.textSecondary),
      ),
    );
  }
}
