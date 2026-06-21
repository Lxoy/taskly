import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/data/models/entry_models.dart';
import 'package:frontend/features/entry/bloc/entry_bloc.dart';
import 'package:frontend/features/entry/presentation/entry_details_sheet.dart';
import 'package:frontend/core/utils/entry_refresh_bus.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final EntryBloc _monthBloc;
  late final EntryBloc _dayBloc;

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    _monthBloc = sl<EntryBloc>();
    _dayBloc = sl<EntryBloc>();
    _fetchMonth();
    _fetchDay(_selectedDay);
    entryRefreshBus.addListener(_refreshAfterMutation);
  }

  @override
  void dispose() {
    entryRefreshBus.removeListener(_refreshAfterMutation);
    _monthBloc.close();
    _dayBloc.close();
    super.dispose();
  }

  void _fetchMonth() {
    _monthBloc.add(EntryMonthOccurrencesRequested(
      year: _focusedMonth.year,
      month: _focusedMonth.month,
    ));
  }

  void _fetchDay(DateTime day) {
    _dayBloc.add(EntryDayOccurrencesRequested(
      year: day.year,
      month: day.month,
      day: day.day,
    ));
  }

  Future<void> _refresh() async {
    _fetchMonth();
    _fetchDay(_selectedDay);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  void _refreshAfterMutation() {
    _fetchMonth();
    _fetchDay(_selectedDay);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
    _fetchMonth();
    _fetchDay(_selectedDay);
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
    _fetchMonth();
    _fetchDay(_selectedDay);
  }

  void _selectDay(DateTime day) {
    setState(() => _selectedDay = day);
    _fetchDay(day);
  }

  String get _monthLabel {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_focusedMonth.month]} ${_focusedMonth.year}';
  }

  Map<int, List<Color>> _dotsFromOccurrences(List<EntryOccurrence> items) {
    final dots = <int, List<Color>>{};

    for (final item in items) {
      if (item.occurrenceDate.year != _focusedMonth.year ||
          item.occurrenceDate.month != _focusedMonth.month) {
        continue;
      }

      final color = switch (item.priority) {
        EntryPriority.low => AppColors.success,
        EntryPriority.medium => AppColors.warning,
        EntryPriority.high => AppColors.danger,
      };

      dots.putIfAbsent(item.occurrenceDate.day, () => <Color>[]).add(color);
    }

    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _monthBloc),
        BlocProvider.value(value: _dayBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calendar',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          _NavButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: _previousMonth,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _monthLabel,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _NavButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: _nextMonth,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        _WeekdayHeader(),
                        const SizedBox(height: AppSpacing.sm),
                        BlocBuilder<EntryBloc, EntryState>(
                          bloc: _monthBloc,
                          builder: (context, state) {
                            final occurrences = state is EntryOccurrencesLoaded
                                ? state.occurrences
                                : <EntryOccurrence>[];

                            return _CalendarGrid(
                              focusedMonth: _focusedMonth,
                              selectedDay: _selectedDay,
                              dots: _dotsFromOccurrences(occurrences),
                              onDayTap: _selectDay,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'ACTIVITIES ${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              BlocBuilder<EntryBloc, EntryState>(
                bloc: _dayBloc,
                builder: (context, state) {
                  if (state is EntryLoading || state is EntryInitial) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is EntryError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          state.message,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  final items = state is EntryOccurrencesLoaded
                      ? state.occurrences
                      : <EntryOccurrence>[];

                  if (items.isEmpty) {
                    return SliverToBoxAdapter(child: _EmptyDay());
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        final isLast = index == items.length - 1;
                        return _CalendarOccurrenceItem(
                          data: item,
                          isLast: isLast,
                          onChanged: _refreshAfterMutation,
                        );
                      },
                      childCount: items.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: _days
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final Map<int, List<Color>> dots;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.dots,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startOffset = firstDay.weekday - 1;
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final prevMonthDays = DateTime(focusedMonth.year, focusedMonth.month, 0).day;

    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - startOffset + 1;

              if (cellIndex < startOffset) {
                final prevDay = prevMonthDays - startOffset + cellIndex + 1;
                return Expanded(
                  child: _DayCell(day: prevDay, isCurrentMonth: false, dots: const []),
                );
              }

              if (dayNumber > daysInMonth) {
                final nextDay = dayNumber - daysInMonth;
                return Expanded(
                  child: _DayCell(day: nextDay, isCurrentMonth: false, dots: const []),
                );
              }

              final isSelected = selectedDay?.day == dayNumber &&
                  selectedDay?.month == focusedMonth.month &&
                  selectedDay?.year == focusedMonth.year;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDayTap(DateTime(
                    focusedMonth.year,
                    focusedMonth.month,
                    dayNumber,
                  )),
                  child: _DayCell(
                    day: dayNumber,
                    isCurrentMonth: true,
                    isSelected: isSelected,
                    dots: dots[dayNumber] ?? [],
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final bool isSelected;
  final List<Color> dots;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    this.isSelected = false,
    required this.dots,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: isSelected
                ? const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)
                : null,
            child: Center(
              child: Text(
                '$day',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isCurrentMonth
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: dots.take(2).map((c) {
              return Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white70 : c,
                  shape: BoxShape.circle,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CalendarOccurrenceItem extends StatelessWidget {
  final EntryOccurrence data;
  final bool isLast;
  final VoidCallback onChanged;

  const _CalendarOccurrenceItem({
    required this.data,
    required this.onChanged,
    this.isLast = false,
  });

  Color get _priorityColor => switch (data.priority) {
        EntryPriority.low => AppColors.success,
        EntryPriority.medium => AppColors.warning,
        EntryPriority.high => AppColors.danger,
      };

  String get _dateLabel => '${data.occurrenceDate.day}.${data.occurrenceDate.month}.';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showOccurrenceDetailsSheet(
        context,
        entryId: data.entryId,
        anomalyId: data.anomalyId,
        occurrenceDate: data.occurrenceDate,
        onChanged: onChanged,
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          isLast ? 0 : AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: _priorityColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                data.title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              _dateLabel,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              data.amount != null ? '${data.amount!.toStringAsFixed(2)} €' : '—',
              style: AppTextStyles.body.copyWith(
                color: data.amount != null ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(
          'No activities for this day.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}
