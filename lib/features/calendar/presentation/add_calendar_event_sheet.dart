import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/calendar_event_model.dart';
import '../../../shared/providers/providers.dart';

class AddCalendarEventSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final CalendarEventModel? editEvent;

  const AddCalendarEventSheet({
    super.key,
    required this.initialDate,
    this.editEvent,
  });

  @override
  ConsumerState<AddCalendarEventSheet> createState() =>
      _AddCalendarEventSheetState();
}

class _AddCalendarEventSheetState
    extends ConsumerState<AddCalendarEventSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _linkedRuleSetId;
  final List<ReminderRule> _reminderRules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editEvent;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _startDate = e?.startAt ?? widget.initialDate;
    _startTime = e != null
        ? TimeOfDay.fromDateTime(e.startAt)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = e != null
        ? TimeOfDay.fromDateTime(e.endAt)
        : const TimeOfDay(hour: 10, minute: 0);
    _linkedRuleSetId = e?.linkedRuleSetId;
    if (e != null) _reminderRules.addAll(e.reminderRules);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addReminderRule() {
    setState(() {
      _reminderRules.add(const ReminderRule(value: 1, unit: 'day'));
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    final startAt = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endAt = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final event = CalendarEventModel(
      id: widget.editEvent?.id ?? '',
      title: title,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      startAt: startAt,
      endAt: endAt,
      reminderRules: _reminderRules,
      linkedRuleSetId: _linkedRuleSetId,
      createdAt: widget.editEvent?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.editEvent != null) {
        await ref
            .read(calendarEventRepositoryProvider)
            .updateEvent(uid, event);
      } else {
        await ref
            .read(calendarEventRepositoryProvider)
            .addEvent(uid, event);
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
    final ruleSets = ref.watch(aiRuleSetsStreamProvider).valueOrNull ?? [];

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
                  widget.editEvent != null
                      ? 'Etkinliği Düzenle'
                      : 'Yeni Etkinlik',
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
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Etkinlik başlığı',
                      prefixIcon: Icon(Icons.event),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama (isteğe bağlı)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _startTime,
                            );
                            if (t != null) setState(() => _startTime = t);
                          },
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(
                            'Başlangıç: ${_startTime.format(context)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                            );
                            if (t != null) setState(() => _endTime = t);
                          },
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(
                            'Bitiş: ${_endTime.format(context)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (ruleSets.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _linkedRuleSetId,
                      decoration: const InputDecoration(
                        labelText: 'AI Kural Seti (isteğe bağlı)',
                        prefixIcon: Icon(Icons.auto_awesome),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Seçilmedi')),
                        ...ruleSets.map((r) => DropdownMenuItem(
                            value: r.id, child: Text(r.name))),
                      ],
                      onChanged: (v) =>
                          setState(() => _linkedRuleSetId = v),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bildirim kuralları',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: _addReminderRule,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ekle'),
                      ),
                    ],
                  ),
                  ..._reminderRules.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final rule = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: rule.value.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Değer',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                final val = int.tryParse(v) ?? 1;
                                setState(() {
                                  _reminderRules[idx] = ReminderRule(
                                    value: val,
                                    unit: rule.unit,
                                  );
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: rule.unit,
                              decoration: const InputDecoration(
                                labelText: 'Birim',
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'minute',
                                    child: Text('Dakika')),
                                DropdownMenuItem(
                                    value: 'hour', child: Text('Saat')),
                                DropdownMenuItem(
                                    value: 'day', child: Text('Gün')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _reminderRules[idx] = ReminderRule(
                                    value: rule.value,
                                    unit: v,
                                  );
                                });
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(
                                  () => _reminderRules.removeAt(idx));
                            },
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                        : Text(widget.editEvent != null
                            ? 'Güncelle'
                            : 'Oluştur'),
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
