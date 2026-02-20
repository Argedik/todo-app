import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/providers.dart';
import 'add_calendar_event_sheet.dart';

class CalendarEventDetailScreen extends ConsumerWidget {
  final String eventId;

  const CalendarEventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events =
        ref.watch(calendarEventsStreamProvider).valueOrNull ?? [];
    final event = events.where((e) => e.id == eventId).firstOrNull;

    if (event == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ruleSets =
        ref.watch(aiRuleSetsStreamProvider).valueOrNull ?? [];
    final linkedRuleSet = event.linkedRuleSetId != null
        ? ruleSets
            .where((r) => r.id == event.linkedRuleSetId)
            .firstOrNull
        : null;

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
                    onPressed: () => _edit(context, event),
                    icon: const Icon(Icons.edit_outlined),
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
                event.title,
                style:
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
              if (event.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  event.description!,
                  style: TextStyle(
                      color: AppColors.textSecondary, height: 1.6),
                ),
              ],
              const SizedBox(height: 24),
              _buildInfoRow(Icons.schedule, 'Başlangıç',
                  AppDateUtils.formatDateTime(event.startAt)),
              _buildInfoRow(Icons.schedule, 'Bitiş',
                  AppDateUtils.formatDateTime(event.endAt)),
              if (event.reminderRules.isNotEmpty) ...[
                const Divider(height: 32),
                const Text('Bildirim Kuralları',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...event.reminderRules.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(r.toReadableString()),
                      ],
                    ),
                  ),
                ),
              ],
              if (linkedRuleSet != null) ...[
                const Divider(height: 32),
                _buildInfoRow(
                    Icons.auto_awesome, 'AI Kural Seti', linkedRuleSet.name),
              ],
              const SizedBox(height: 32),
              if (event.linkedRuleSetId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _generateMessage(context, ref, event),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Mesaj Üret'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _generateMessage(
      BuildContext context, WidgetRef ref, CalendarEventModel event) async {
    // TODO: Cloud Function çağrısı yapılacak
    // Şimdilik placeholder mesaj oluştur
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mesaj üretiliyor...')),
    );

    final message = GeneratedMessageModel(
      id: '',
      title: '${event.title} - Mesaj',
      content:
          'Bu mesaj "${event.title}" etkinliği için AI tarafından üretilecektir.\n\n'
          'Cloud Functions kurulumu tamamlandığında gerçek AI mesajı burada görünecek.',
      sourceEventId: event.id,
      ruleSetId: event.linkedRuleSetId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(messageRepositoryProvider).addMessage(uid, message);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj oluşturuldu!')),
      );
    }
  }

  void _edit(BuildContext context, CalendarEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCalendarEventSheet(
        initialDate: event.startAt,
        editEvent: event,
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Etkinliği Sil'),
        content: const Text(
            'Bu etkinliği silmek istediğinize emin misiniz?'),
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
            .read(calendarEventRepositoryProvider)
            .deleteEvent(uid, eventId);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}
