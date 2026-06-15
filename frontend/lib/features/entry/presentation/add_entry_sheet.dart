import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/core/utils/icon_registry.dart';
import 'package:frontend/data/models/category_models.dart';
import 'package:frontend/data/models/entry_models.dart';
import 'package:frontend/features/categories/bloc/category_bloc.dart';
import 'package:frontend/features/entry/bloc/entry_bloc.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

void showAddEntrySheet(BuildContext context) {
  final categoryBloc = context.read<CategoryBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: categoryBloc),
        BlocProvider(create: (_) => sl<EntryBloc>()),
      ],
      child: const _AddEntrySheet(),
    ),
  );
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet();

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _titleCtrl       = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _amountCtrl      = TextEditingController();

  EntryPriority        _priority   = EntryPriority.medium;
  EntryRecurrenceType  _recurrence = EntryRecurrenceType.monthly;
  int                  _interval   = 1;
  DateTime?            _scheduledDate;
  DateTime?            _recurrenceEndDate;
  int?                 _categoryId;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) return 'Title is required.';
    if (_scheduledDate == null) return 'Date & time is required.';
    if (_recurrence != EntryRecurrenceType.once &&
        _recurrenceEndDate == null) return 'End date is required.';
    return null;
  }

  void _onSave() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
      return;
    }

    final amount = double.tryParse(
        _amountCtrl.text.replaceAll(',', '.').trim());

    context.read<EntryBloc>().add(
          EntryCreateRequested(
            CreateEntryRequest(
              categoryId:        _categoryId,
              title:             _titleCtrl.text.trim(),
              description:       _descriptionCtrl.text.trim().isEmpty
                  ? null
                  : _descriptionCtrl.text.trim(),
              amount:            amount,
              priority:          _priority,
              recurrenceType:    _recurrence,
              recurrenceInterval: _interval,
              scheduledDate:     _scheduledDate!,
              recurrenceEndDate: _recurrenceEndDate,
            ),
          ),
        );
  }

  // ── Date + time picker ────────────────────────────────────────────────────

  Future<void> _pickDateTime({required bool isEnd}) async {
    final now  = DateTime.now();
    final init = isEnd
        ? (_recurrenceEndDate ?? _scheduledDate ?? now)
        : (_scheduledDate ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: isEnd ? (_scheduledDate ?? now) : now,
      lastDate: DateTime(now.year + 100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isEnd) {
        _recurrenceEndDate = combined;
      } else {
        _scheduledDate = combined;
        if (_recurrenceEndDate != null &&
            _recurrenceEndDate!.isBefore(combined)) {
          _recurrenceEndDate = null;
        }
      }
    });
  }

  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return 'Pick date & time';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}  $h:$m';
  }

  String _intervalUnit() => switch (_recurrence) {
        EntryRecurrenceType.daily   => _interval == 1 ? 'day'   : 'days',
        EntryRecurrenceType.weekly  => _interval == 1 ? 'week'  : 'weeks',
        EntryRecurrenceType.monthly => _interval == 1 ? 'month' : 'months',
        EntryRecurrenceType.yearly  => _interval == 1 ? 'year'  : 'years',
        EntryRecurrenceType.once    => '',
      };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<EntryBloc, EntryState>(
      listener: (context, state) {
        if (state is EntryCreated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Activity saved!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          );
        }
        if (state is EntryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Activity',
                        style: AppTextStyles.subtitle
                            .copyWith(color: AppColors.textPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  height: 1),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md,
                    AppSpacing.md, AppSpacing.md + bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Title
                      _Label('Title'),
                      const SizedBox(height: AppSpacing.sm),
                      _InputField(
                        controller: _titleCtrl,
                        hint: 'e.g. Electricity, Netflix...',
                        icon: Icons.edit_outlined,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Description
                      _Label('Description (optional)'),
                      const SizedBox(height: AppSpacing.sm),
                      _InputField(
                        controller: _descriptionCtrl,
                        hint: 'Short description...',
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Amount
                      _Label('Amount (optional)'),
                      const SizedBox(height: AppSpacing.sm),
                      _InputField(
                        controller: _amountCtrl,
                        hint: '0.00',
                        icon: Icons.euro_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]')),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Category
                      _Label('Category'),
                      const SizedBox(height: AppSpacing.sm),
                      _CategoryPicker(
                        selectedId: _categoryId,
                        onChanged: (id) =>
                            setState(() => _categoryId = id),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Priority
                      _Label('Priority'),
                      const SizedBox(height: AppSpacing.sm),
                      _SegmentedPriority(
                        selected: _priority,
                        onSelect: (p) => setState(() => _priority = p),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Repeat
                      _Label('Repeat'),
                      const SizedBox(height: AppSpacing.sm),
                      _RecurrenceChips(
                        selected: _recurrence,
                        onSelect: (r) => setState(() => _recurrence = r),
                      ),

                      // Interval
                      if (_recurrence != EntryRecurrenceType.once) ...[
                        const SizedBox(height: AppSpacing.md),
                        _IntervalRow(
                          value: _interval,
                          unit: _intervalUnit(),
                          onDecrement: () => setState(
                              () => _interval = (_interval - 1).clamp(1, 99)),
                          onIncrement: () => setState(
                              () => _interval = (_interval + 1).clamp(1, 99)),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),

                      // Date & Time
                      _Label('Date & Time'),
                      const SizedBox(height: AppSpacing.sm),
                      _DateTimeButton(
                        label: _fmtDateTime(_scheduledDate),
                        hasValue: _scheduledDate != null,
                        onTap: () => _pickDateTime(isEnd: false),
                      ),

                      // End date
                      if (_recurrence != EntryRecurrenceType.once) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _Label('End Date'),
                        const SizedBox(height: AppSpacing.sm),
                        _DateTimeButton(
                          label: _fmtDateTime(_recurrenceEndDate),
                          hasValue: _recurrenceEndDate != null,
                          onTap: () => _pickDateTime(isEnd: true),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),

                      // Save button
                      BlocBuilder<EntryBloc, EntryState>(
                        builder: (context, state) {
                          final isLoading = state is EntryLoading;
                          return GestureDetector(
                            onTap: isLoading ? null : _onSave,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isLoading ? 0.7 : 1.0,
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22, height: 22,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5),
                                        )
                                      : Text('Save Activity',
                                          style: AppTextStyles.body.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category picker ───────────────────────────────────────────────────────────

class _CategoryPicker extends StatelessWidget {
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _CategoryPicker(
      {required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = switch (state) {
          CategoryLoaded(:final categories)   => categories,
          CategoryMutating(:final categories) => categories,
          _                                   => <Category>[],
        };

        if (state is CategoryLoading || state is CategoryInitial) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        }

        if (categories.isEmpty) {
          return Text(
            'No categories yet. Add them in Profile → Categories.',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          );
        }

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.map((cat) {
            final sel      = selectedId == cat.id;
            final catColor = _hexToColor(cat.color);
            final iconData = IconRegistry.get(cat.icon);

            return GestureDetector(
              onTap: () => onChanged(sel ? null : cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? catColor : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: sel ? catColor : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData,
                        size: 14,
                        color: sel
                            ? Colors.white
                            : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(cat.name,
                        style: AppTextStyles.caption.copyWith(
                          color: sel
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: sel
                              ? FontWeight.w600
                              : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Segmented priority ────────────────────────────────────────────────────────

class _SegmentedPriority extends StatelessWidget {
  final EntryPriority selected;
  final ValueChanged<EntryPriority> onSelect;

  const _SegmentedPriority(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: EntryPriority.values.map((p) {
          final sel     = selected == p;
          final isFirst = p == EntryPriority.low;
          final isLast  = p == EntryPriority.high;
          final color   = switch (p) {
            EntryPriority.low    => AppColors.success,
            EntryPriority.medium => AppColors.warning,
            EntryPriority.high   => AppColors.danger,
          };
          final label = switch (p) {
            EntryPriority.low    => 'Low',
            EntryPriority.medium => 'Medium',
            EntryPriority.high   => 'High',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? color : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst
                        ? const Radius.circular(AppRadius.md - 1)
                        : Radius.zero,
                    right: isLast
                        ? const Radius.circular(AppRadius.md - 1)
                        : Radius.zero,
                  ),
                ),
                child: Center(
                  child: Text(label,
                      style: AppTextStyles.caption.copyWith(
                        color: sel
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: sel
                            ? FontWeight.w600
                            : FontWeight.w400,
                      )),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Recurrence chips ──────────────────────────────────────────────────────────

class _RecurrenceChips extends StatelessWidget {
  final EntryRecurrenceType selected;
  final ValueChanged<EntryRecurrenceType> onSelect;

  const _RecurrenceChips(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: EntryRecurrenceType.values.map((r) {
        final sel   = selected == r;
        final label = switch (r) {
          EntryRecurrenceType.once    => 'Once',
          EntryRecurrenceType.daily   => 'Daily',
          EntryRecurrenceType.weekly  => 'Weekly',
          EntryRecurrenceType.monthly => 'Monthly',
          EntryRecurrenceType.yearly  => 'Yearly',
        };
        return GestureDetector(
          onTap: () => onSelect(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: sel
                    ? AppColors.primary
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(label,
                style: AppTextStyles.caption.copyWith(
                  color: sel ? Colors.white : AppColors.textSecondary,
                  fontWeight:
                      sel ? FontWeight.w600 : FontWeight.w400,
                )),
          ),
        );
      }).toList(),
    );
  }
}

// ── Interval row ──────────────────────────────────────────────────────────────

class _IntervalRow extends StatelessWidget {
  final int value;
  final String unit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _IntervalRow({
    required this.value,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat_rounded,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text('Every',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          _StepBtn(
              icon: Icons.remove_rounded,
              enabled: value > 1,
              onTap: onDecrement),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 32,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StepBtn(
              icon: Icons.add_rounded,
              enabled: value < 99,
              onTap: onIncrement),
          const SizedBox(width: AppSpacing.sm),
          Text(unit,
              style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Date & time button ────────────────────────────────────────────────────────

class _DateTimeButton extends StatelessWidget {
  final String label;
  final bool hasValue;
  final VoidCallback onTap;

  const _DateTimeButton(
      {required this.label, required this.hasValue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: hasValue
                ? AppColors.primary.withOpacity(0.4)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 16,
                color: hasValue
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(label,
                style: AppTextStyles.body.copyWith(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight:
                      hasValue ? FontWeight.w500 : FontWeight.w400,
                )),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Step button ───────────────────────────────────────────────────────────────

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon,
            size: 18,
            color:
                enabled ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary.withOpacity(0.5)),
          prefixIcon:
              Icon(icon, size: 18, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
        ),
      ),
    );
  }
}

// ── Label ─────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}