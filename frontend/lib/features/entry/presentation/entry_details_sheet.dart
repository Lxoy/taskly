import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/utils/icon_registry.dart';
import 'package:frontend/data/models/category_models.dart';
import 'package:frontend/data/models/entry_models.dart';
import 'package:frontend/features/categories/bloc/category_bloc.dart';
import 'package:frontend/features/entry/bloc/entry_bloc.dart';

void showOccurrenceDetailsSheet(
  BuildContext context, {
  required int entryId,
  required int? anomalyId,
  required DateTime occurrenceDate,
  VoidCallback? onChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = sl<EntryBloc>();
            if (anomalyId != null) {
              bloc.add(EntryAnomalyDetailsRequested(anomalyId));
            } else {
              bloc.add(EntryDetailsRequested(entryId));
            }
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) => sl<CategoryBloc>()..add(const CategoriesFetchRequested()),
        ),
      ],
      child: _OccurrenceDetailsSheet(
        occurrenceDate: occurrenceDate,
        onChanged: onChanged,
      ),
    ),
  );
}

class _OccurrenceDetailsSheet extends StatelessWidget {
  final DateTime occurrenceDate;
  final VoidCallback? onChanged;

  const _OccurrenceDetailsSheet({
    required this.occurrenceDate,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<EntryBloc, EntryState>(
      listener: (context, state) {
        if (state is EntryUpdated || state is EntryDeleted) {
          onChanged?.call();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved.')),
          );
        }
        if (state is EntryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.64,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: BlocBuilder<EntryBloc, EntryState>(
              builder: (context, state) {
                if (state is EntryLoading || state is EntryInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is EntryError) {
                  return _ErrorContent(message: state.message);
                }

                if (state is! EntryDetailsLoaded) {
                  return const _ErrorContent(message: 'Nothing to show.');
                }

                final details = state.details;
                final displayDate = details.anomalyId == null
                    ? occurrenceDate
                    : details.displayDate;

                return BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, categoryState) {
                    final category = _findCategory(categoryState, details.categoryId);
                    final categoryColor = category != null
                        ? _hexToColor(category.color)
                        : AppColors.primary;
                    final categoryIcon = category != null
                        ? IconRegistry.get(category.icon)
                        : Icons.receipt_long_rounded;

                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(categoryIcon, color: categoryColor, size: 22),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      details.title,
                                      style: AppTextStyles.subtitle.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (category != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        category.name,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _InfoRow(
                            icon: Icons.schedule_rounded,
                            label: 'Date',
                            value: _formatDateTime(displayDate),
                            color: AppColors.primary,
                          ),
                          _InfoRow(
                            icon: Icons.flag_rounded,
                            label: 'Priority',
                            value: _priorityLabel(details.priority),
                            color: _priorityColor(details.priority),
                          ),
                          _InfoRow(
                            icon: Icons.euro_rounded,
                            label: 'Amount',
                            value: details.amount != null
                                ? '${details.amount!.toStringAsFixed(2)} €'
                                : '—',
                            color: AppColors.primary,
                          ),
                          if (category != null)
                            _InfoRow(
                              icon: categoryIcon,
                              label: 'Category',
                              value: category.name,
                              color: categoryColor,
                            ),
                          if (details.description != null &&
                              details.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Description',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Text(
                                details.description!,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  label: 'Edit',
                                  icon: Icons.edit_rounded,
                                  onTap: () => _showEditSheet(
                                    context,
                                    details,
                                    displayDate,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _ActionButton(
                                  label: 'Delete',
                                  icon: Icons.delete_outline_rounded,
                                  isDanger: true,
                                  onTap: () => _showDeleteSheet(
                                    context,
                                    details,
                                    displayDate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    OccurrenceDetails details,
    DateTime date,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<EntryBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: _EditOccurrenceSheet(
          details: details,
          occurrenceDate: date,
        ),
      ),
    );
  }

  void _showDeleteSheet(
    BuildContext context,
    OccurrenceDetails details,
    DateTime date,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<EntryBloc>(),
        child: _DeleteOccurrenceSheet(
          details: details,
          occurrenceDate: date,
        ),
      ),
    );
  }
}

enum _EditScope { thisOccurrence, all, future }

class _EditOccurrenceSheet extends StatefulWidget {
  final OccurrenceDetails details;
  final DateTime occurrenceDate;

  const _EditOccurrenceSheet({
    required this.details,
    required this.occurrenceDate,
  });

  @override
  State<_EditOccurrenceSheet> createState() => _EditOccurrenceSheetState();
}

class _EditOccurrenceSheetState extends State<_EditOccurrenceSheet> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  EntryPriority _priority = EntryPriority.medium;
  EntryRecurrenceType _recurrence = EntryRecurrenceType.once;
  int _interval = 1;
  int _recurrenceDaysMask = 0;
  DateTime? _scheduledDate;
  DateTime? _recurrenceEndDate;
  int? _categoryId;
  bool _titleError = false;
  bool _dateError = false;
  bool _weekDaysError = false;
  bool _endDateError = false;
  _EditScope _scope = _EditScope.thisOccurrence;

  @override
  void initState() {
    super.initState();

    final details = widget.details;
    _titleCtrl.text = details.title;
    _descriptionCtrl.text = details.description ?? '';
    _amountCtrl.text = details.amount?.toStringAsFixed(2) ?? '';
    _priority = details.priority;
    _categoryId = details.categoryId;
    _scheduledDate = widget.occurrenceDate;

    if (details is EntryDetails) {
      _recurrence = details.recurrenceType;
      _interval = details.recurrenceInterval;
      _recurrenceDaysMask = details.recurrenceDaysMask ?? 0;
      _recurrenceEndDate = details.recurrenceEndDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _isAnomaly => widget.details.anomalyId != null;

  bool get _showRecurrence => widget.details is EntryDetails && _scope != _EditScope.thisOccurrence;

  bool _validateFields() {
    final hasTitleError = _titleCtrl.text.trim().isEmpty;
    final hasDateError = _scheduledDate == null;
    final hasWeekDaysError = _showRecurrence &&
        _recurrence == EntryRecurrenceType.weekly &&
        _recurrenceDaysMask == 0;
    final hasEndDateError = _showRecurrence &&
        _recurrence != EntryRecurrenceType.once &&
        _recurrenceEndDate == null;

    setState(() {
      _titleError = hasTitleError;
      _dateError = hasDateError;
      _weekDaysError = hasWeekDaysError;
      _endDateError = hasEndDateError;
    });

    return !(hasTitleError ||
        hasDateError ||
        hasWeekDaysError ||
        hasEndDateError);
  }

  Future<void> _pickDateTime({required bool isEnd}) async {
    final now = DateTime.now();
    final init = isEnd
        ? (_recurrenceEndDate ?? _scheduledDate ?? now)
        : (_scheduledDate ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isEnd) {
        _recurrenceEndDate = combined;
        _endDateError = false;
      } else {
        _scheduledDate = combined;
        _dateError = false;
        if (_recurrenceEndDate != null &&
            _recurrenceEndDate!.isBefore(combined)) {
          _recurrenceEndDate = null;
        }
      }
    });
  }

  String _intervalUnit() => switch (_recurrence) {
        EntryRecurrenceType.daily => _interval == 1 ? 'day' : 'days',
        EntryRecurrenceType.weekly => _interval == 1 ? 'week' : 'weeks',
        EntryRecurrenceType.monthly => _interval == 1 ? 'month' : 'months',
        EntryRecurrenceType.yearly => _interval == 1 ? 'year' : 'years',
        EntryRecurrenceType.once => '',
      };

  void _save() {
    if (!_validateFields()) return;

    final title = _titleCtrl.text.trim();
    final description = _descriptionCtrl.text.trim().isEmpty
        ? null
        : _descriptionCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    final details = widget.details;
    final bloc = context.read<EntryBloc>();

    if (details.anomalyId != null && _scope == _EditScope.thisOccurrence) {
      bloc.add(
        EntryAnomalyEditRequested(
          anomalyId: details.anomalyId!,
          request: EditEntryAnomalyRequest(
            occurrenceDate: details is AnomalyDetails
                ? details.occurrenceDate
                : widget.occurrenceDate,
            newOccurrenceDate: _scheduledDate,
            title: title,
            description: description,
            amount: amount,
            priority: _priority,
            categoryId: _categoryId,
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    switch (_scope) {
      case _EditScope.thisOccurrence:
        bloc.add(
          EntryAnomalyCreateRequested(
            entryId: details.entryId,
            request: CreateEntryAnomalyRequest(
              occurrenceDate: widget.occurrenceDate,
              newOccurrenceDate: _scheduledDate,
              title: title,
              description: description,
              amount: amount,
              priority: _priority,
              categoryId: _categoryId,
            ),
          ),
        );
        break;
      case _EditScope.all:
        bloc.add(
          EntryUpdateAllRequested(
            entryId: details.entryId,
            request: UpdateEntryRequest(
              categoryId: _categoryId,
              title: title,
              description: description,
              amount: amount,
              priority: _priority,
              recurrenceType: _showRecurrence ? _recurrence : null,
              recurrenceInterval: _showRecurrence ? _interval : null,
              recurrenceDaysMask: _showRecurrence && _recurrence == EntryRecurrenceType.weekly
                  ? _recurrenceDaysMask
                  : null,
              scheduledDate: _scheduledDate,
              recurrenceEndDate: _showRecurrence ? _recurrenceEndDate : null,
            ),
          ),
        );
        break;
      case _EditScope.future:
        bloc.add(
          EntryUpdateThisAndFutureRequested(
            entryId: details.entryId,
            request: UpdateEntryThisAndFutureRequest(
              effectiveDate: widget.occurrenceDate,
              categoryId: _categoryId,
              title: title,
              description: description,
              amount: amount,
              priority: _priority,
              recurrenceType: _showRecurrence ? _recurrence : null,
              recurrenceInterval: _showRecurrence ? _interval : null,
              recurrenceDaysMask: _showRecurrence && _recurrence == EntryRecurrenceType.weekly
                  ? _recurrenceDaysMask
                  : null,
              scheduledDate: _scheduledDate,
              recurrenceEndDate: _showRecurrence ? _recurrenceEndDate : null,
            ),
          ),
        );
        break;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
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
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Activity',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(
              color: AppColors.textSecondary.withOpacity(0.1),
              height: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md + bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (true) ...[
                      _Label('Edit scope'),
                      const SizedBox(height: AppSpacing.sm),
                      _ScopeSelector(
                        value: _scope,
                        onChanged: (value) => setState(() => _scope = value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _Label('Title'),
                    const SizedBox(height: AppSpacing.sm),
                    _InputField(
                      controller: _titleCtrl,
                      hint: 'e.g. Electricity, Netflix...',
                      icon: Icons.edit_outlined,
                      hasError: _titleError,
                      errorText: 'Title is required.',
                      onChanged: (_) {
                        if (_titleError && _titleCtrl.text.trim().isNotEmpty) {
                          setState(() => _titleError = false);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Label('Description (optional)'),
                    const SizedBox(height: AppSpacing.sm),
                    _InputField(
                      controller: _descriptionCtrl,
                      hint: 'Short description...',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Label('Amount (optional)'),
                    const SizedBox(height: AppSpacing.sm),
                    _InputField(
                      controller: _amountCtrl,
                      hint: '0.00',
                      icon: Icons.euro_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Label('Category'),
                    const SizedBox(height: AppSpacing.sm),
                    _CategoryPicker(
                      selectedId: _categoryId,
                      onChanged: (id) => setState(() => _categoryId = id),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Label('Priority'),
                    const SizedBox(height: AppSpacing.sm),
                    _SegmentedPriority(
                      selected: _priority,
                      onSelect: (p) => setState(() => _priority = p),
                    ),
                    if (_showRecurrence) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _Label('Repeat'),
                      const SizedBox(height: AppSpacing.sm),
                      _RecurrenceChips(
                        selected: _recurrence,
                        onSelect: (r) => setState(() {
                          _recurrence = r;
                          _endDateError = false;
                          if (r != EntryRecurrenceType.weekly) {
                            _recurrenceDaysMask = 0;
                            _weekDaysError = false;
                          }
                        }),
                      ),
                      if (_recurrence != EntryRecurrenceType.once) ...[
                        const SizedBox(height: AppSpacing.md),
                        _IntervalRow(
                          value: _interval,
                          unit: _intervalUnit(),
                          onDecrement: () => setState(
                            () => _interval = (_interval - 1).clamp(1, 99),
                          ),
                          onIncrement: () => setState(
                            () => _interval = (_interval + 1).clamp(1, 99),
                          ),
                        ),
                      ],
                      if (_recurrence == EntryRecurrenceType.weekly) ...[
                        const SizedBox(height: AppSpacing.md),
                        _Label('Repeat on'),
                        const SizedBox(height: AppSpacing.sm),
                        _WeekdaySelector(
                          selectedMask: _recurrenceDaysMask,
                          onChanged: (mask) => setState(() {
                            _recurrenceDaysMask = mask;
                            if (mask != 0) _weekDaysError = false;
                          }),
                        ),
                        if (_weekDaysError)
                          const _FieldErrorText('Select at least one weekday.'),
                      ],
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _Label('Date & Time'),
                    const SizedBox(height: AppSpacing.sm),
                    _DateTimeButton(
                      label: _scheduledDate == null
                          ? 'Pick date & time'
                          : _formatDateTime(_scheduledDate!),
                      hasValue: _scheduledDate != null,
                      hasError: _dateError,
                      errorText: 'Date & time is required.',
                      onTap: () => _pickDateTime(isEnd: false),
                    ),
                    if (_showRecurrence && _recurrence != EntryRecurrenceType.once) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _Label('End Date'),
                      const SizedBox(height: AppSpacing.sm),
                      _DateTimeButton(
                        label: _recurrenceEndDate == null
                            ? 'Pick date & time'
                            : _formatDateTime(_recurrenceEndDate!),
                        hasValue: _recurrenceEndDate != null,
                        hasError: _endDateError,
                        errorText: 'End date is required.',
                        onTap: () => _pickDateTime(isEnd: true),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    _PrimarySaveButton(onTap: _save),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteOccurrenceSheet extends StatelessWidget {
  final OccurrenceDetails details;
  final DateTime occurrenceDate;

  const _DeleteOccurrenceSheet({
    required this.details,
    required this.occurrenceDate,
  });

  @override
  Widget build(BuildContext context) {
    final isAnomaly = details.anomalyId != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delete',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _DeleteOption(
            title: 'Delete this occurrence',
            subtitle: isAnomaly
                ? 'Removes only this changed occurrence.'
                : 'Removes only this generated occurrence.',
            onTap: () {
              if (isAnomaly) {
                context.read<EntryBloc>().add(
                      EntryAnomalyDeleteRequested(details.anomalyId!),
                    );
              } else {
                context.read<EntryBloc>().add(
                      EntryDeleteRequested(
                        entryId: details.entryId,
                        effectiveDate: occurrenceDate,
                      ),
                    );
              }
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _DeleteOption(
            title: 'Delete this and future',
            subtitle: 'Keeps previous occurrences and removes future ones.',
            onTap: () {
              context.read<EntryBloc>().add(
                    EntryDeleteFutureRequested(
                      entryId: details.entryId,
                      effectiveDate: occurrenceDate,
                    ),
                  );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _DeleteOption(
            title: 'Delete all',
            subtitle: 'Removes the whole recurring series.',
            onTap: () {
              context.read<EntryBloc>().add(EntryDeleteAllRequested(details.entryId));
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _DeleteOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DeleteOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeSelector extends StatelessWidget {
  final _EditScope value;
  final ValueChanged<_EditScope> onChanged;

  const _ScopeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScopeTile(
          label: 'Only this occurrence',
          subtitle: 'Create or update one occurrence only.',
          value: _EditScope.thisOccurrence,
          groupValue: value,
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ScopeTile(
          label: 'All occurrences',
          subtitle: 'Apply changes to the whole series.',
          value: _EditScope.all,
          groupValue: value,
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ScopeTile(
          label: 'This and future',
          subtitle: 'Keep previous occurrences unchanged.',
          value: _EditScope.future,
          groupValue: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ScopeTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final _EditScope value;
  final _EditScope groupValue;
  final ValueChanged<_EditScope> onChanged;

  const _ScopeTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _CategoryPicker({
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = switch (state) {
          CategoryLoaded(:final categories) => categories,
          CategoryMutating(:final categories) => categories,
          CategoryError(:final categories) => categories,
          _ => <Category>[],
        };

        if (state is CategoryLoading || state is CategoryInitial) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (categories.isEmpty) {
          return Text(
            'No categories yet. Add them in Profile → Categories.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          );
        }

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.map((cat) {
            final selected = selectedId == cat.id;
            final catColor = _hexToColor(cat.color);
            final iconData = IconRegistry.get(cat.icon);

            return GestureDetector(
              onTap: () => onChanged(selected ? null : cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? catColor : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: selected ? catColor : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconData,
                      size: 14,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: AppTextStyles.caption.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
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

class _SegmentedPriority extends StatelessWidget {
  final EntryPriority selected;
  final ValueChanged<EntryPriority> onSelect;

  const _SegmentedPriority({
    required this.selected,
    required this.onSelect,
  });

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
          final selectedItem = selected == p;
          final isFirst = p == EntryPriority.low;
          final isLast = p == EntryPriority.high;
          final color = _priorityColor(p);

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedItem ? color : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(AppRadius.md - 1) : Radius.zero,
                    right: isLast ? const Radius.circular(AppRadius.md - 1) : Radius.zero,
                  ),
                ),
                child: Center(
                  child: Text(
                    _priorityLabel(p),
                    style: AppTextStyles.caption.copyWith(
                      color: selectedItem ? Colors.white : AppColors.textSecondary,
                      fontWeight: selectedItem ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  final int selectedMask;
  final ValueChanged<int> onChanged;

  const _WeekdaySelector({
    required this.selectedMask,
    required this.onChanged,
  });

  static const _days = [
    _WeekdayOption(label: 'Mon', mask: 1),
    _WeekdayOption(label: 'Tue', mask: 2),
    _WeekdayOption(label: 'Wed', mask: 4),
    _WeekdayOption(label: 'Thu', mask: 8),
    _WeekdayOption(label: 'Fri', mask: 16),
    _WeekdayOption(label: 'Sat', mask: 32),
    _WeekdayOption(label: 'Sun', mask: 64),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _days.map((day) {
        final selected = (selectedMask & day.mask) != 0;

        return GestureDetector(
          onTap: () {
            final nextMask = selected
                ? selectedMask & ~day.mask
                : selectedMask | day.mask;
            onChanged(nextMask);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 44,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
              ),
            ),
            child: Center(
              child: Text(
                day.label,
                style: AppTextStyles.caption.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekdayOption {
  final String label;
  final int mask;

  const _WeekdayOption({
    required this.label,
    required this.mask,
  });
}

class _RecurrenceChips extends StatelessWidget {
  final EntryRecurrenceType selected;
  final ValueChanged<EntryRecurrenceType> onSelect;

  const _RecurrenceChips({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: EntryRecurrenceType.values.map((r) {
        final selectedItem = selected == r;
        final label = switch (r) {
          EntryRecurrenceType.once => 'Once',
          EntryRecurrenceType.daily => 'Daily',
          EntryRecurrenceType.weekly => 'Weekly',
          EntryRecurrenceType.monthly => 'Monthly',
          EntryRecurrenceType.yearly => 'Yearly',
        };

        return GestureDetector(
          onTap: () => onSelect(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selectedItem ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: selectedItem ? AppColors.primary : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selectedItem ? Colors.white : AppColors.textSecondary,
                fontWeight: selectedItem ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

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
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Every',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          _StepBtn(
            icon: Icons.remove_rounded,
            enabled: value > 1,
            onTap: onDecrement,
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StepBtn(
            icon: Icons.add_rounded,
            enabled: value < 99,
            onTap: onIncrement,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            unit,
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  final String label;
  final bool hasValue;
  final bool hasError;
  final String? errorText;
  final VoidCallback onTap;

  const _DateTimeButton({
    required this.label,
    required this.hasValue,
    required this.onTap,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasError
                    ? AppColors.danger
                    : hasValue
                        ? AppColors.primary.withOpacity(0.4)
                        : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: hasError
                      ? AppColors.danger
                      : hasValue
                          ? AppColors.primary
                          : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: hasError
                        ? AppColors.danger
                        : hasValue
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                    fontWeight:
                        hasValue || hasError ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (hasError && errorText != null) _FieldErrorText(errorText!),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary.withOpacity(0.1) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.hasError = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: hasError ? AppColors.danger : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: hasError ? AppColors.danger : AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        if (hasError && errorText != null) _FieldErrorText(errorText!),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.danger : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimarySaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimarySaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Save Changes',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );
}



class _FieldErrorText extends StatelessWidget {
  final String message;

  const _FieldErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  const _ErrorContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

Category? _findCategory(CategoryState state, int? categoryId) {
  if (categoryId == null) return null;

  final categories = switch (state) {
    CategoryLoaded(:final categories) => categories,
    CategoryMutating(:final categories) => categories,
    CategoryError(:final categories) => categories,
    _ => <Category>[],
  };

  for (final category in categories) {
    if (category.id == categoryId) return category;
  }

  return null;
}

Color _hexToColor(String hex) {
  final normalized = hex.replaceAll('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

Color _priorityColor(EntryPriority priority) => switch (priority) {
      EntryPriority.low => AppColors.success,
      EntryPriority.medium => AppColors.warning,
      EntryPriority.high => AppColors.danger,
    };

String _priorityLabel(EntryPriority priority) => switch (priority) {
      EntryPriority.low => 'Low',
      EntryPriority.medium => 'Medium',
      EntryPriority.high => 'High',
    };

String _formatDateTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  $h:$m';
}
