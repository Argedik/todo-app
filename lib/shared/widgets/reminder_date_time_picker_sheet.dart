import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';

class ReminderDateTimePickerResult {
  final DateTime dateTime;

  const ReminderDateTimePickerResult({required this.dateTime});
}

class ReminderDateTimePickerSheet extends StatefulWidget {
  final DateTime? initialDateTime;
  final VoidCallback? onRemove;

  const ReminderDateTimePickerSheet({
    super.key,
    this.initialDateTime,
    this.onRemove,
  });

  static Future<ReminderDateTimePickerResult?> show(
    BuildContext context, {
    DateTime? initialDateTime,
    VoidCallback? onRemove,
  }) {
    return showModalBottomSheet<ReminderDateTimePickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReminderDateTimePickerSheet(
        initialDateTime: initialDateTime,
        onRemove: onRemove,
      ),
    );
  }

  @override
  State<ReminderDateTimePickerSheet> createState() =>
      _ReminderDateTimePickerSheetState();
}

class _ReminderDateTimePickerSheetState
    extends State<ReminderDateTimePickerSheet> {
  int _step = 0;
  DateTime? _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.initialDateTime != null) {
      _selectedDate = DateTime(
        widget.initialDateTime!.year,
        widget.initialDateTime!.month,
        widget.initialDateTime!.day,
      );
      _selectedHour = widget.initialDateTime!.hour;
      _selectedMinute = widget.initialDateTime!.minute;
    } else {
      _selectedHour = (now.hour + 1) % 24;
      _selectedMinute = 0;
    }
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _step = 1;
    });
  }

  void _confirm() {
    if (_selectedDate == null) return;

    final combinedDateTime = AppDateUtils.combineDateAndTime(
      _selectedDate!,
      _selectedHour,
      _selectedMinute,
    );

    if (AppDateUtils.isPastDateTime(combinedDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçmiş bir saat seçilemez'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      ReminderDateTimePickerResult(dateTime: combinedDateTime.toUtc()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_step == 1)
                  IconButton(
                    onPressed: () => setState(() => _step = 0),
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                  ),
                Expanded(
                  child: Text(
                    _step == 0 ? 'Tarih Seçin' : 'Saat Seçin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: _step == 0 ? TextAlign.center : TextAlign.start,
                  ),
                ),
                if (widget.onRemove != null && widget.initialDateTime != null)
                  TextButton(
                    onPressed: () {
                      widget.onRemove?.call();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kaldır',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _step == 0 ? _buildDatePicker() : _buildTimePicker(),
            ),
            const SizedBox(height: 20),
            if (_step == 1)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SizedBox(
      key: const ValueKey('date'),
      height: 320,
      child: CalendarDatePicker(
        initialDate: _selectedDate ?? today,
        firstDate: today,
        lastDate: today.add(const Duration(days: 365 * 5)),
        onDateChanged: _onDateSelected,
      ),
    );
  }

  Widget _buildTimePicker() {
    return SizedBox(
      key: const ValueKey('time'),
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: CupertinoPicker(
              scrollController: _hourController,
              itemExtent: 44,
              onSelectedItemChanged: (index) {
                setState(() => _selectedHour = index);
              },
              children: List.generate(
                24,
                (i) => Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 80,
            child: CupertinoPicker(
              scrollController: _minuteController,
              itemExtent: 44,
              onSelectedItemChanged: (index) {
                setState(() => _selectedMinute = index);
              },
              children: List.generate(
                60,
                (i) => Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
