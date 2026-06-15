import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(2026, 5);
  DateTime? _selectedDay = DateTime(2026, 5, 9);

  // Dummy dot data — datum: lista boja točkica
  final Map<int, List<Color>> _dots = {
    9:  [AppColors.danger],
    20: [AppColors.warning],
    25: [AppColors.secondary],
    28: [AppColors.textSecondary],
  };

  // Dummy obveze za ovaj mjesec
  static const _obligations = [
    _ObligationData(title: 'Struja',           date: '12.5.',  amount: '45,00 €',  amountColor: _red),
    _ObligationData(title: 'Registracija auta', date: '20.5.', amount: '185,00 €', amountColor: _dark),
    _ObligationData(title: 'Netflix',           date: '25.5.', amount: '13,99 €',  amountColor: _dark),
    _ObligationData(title: 'Zubar — termin',    date: '28.5.', amount: '—',        amountColor: _gray),
  ];

  static const _red  = Color(0xFFEF4444);
  static const _dark = Color(0xFF111827);
  static const _gray = Color(0xFF6B7280);

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = null;
    });
  }

  String get _monthLabel {
    const months = [
      '', 'Siječanj', 'Veljača', 'Ožujak', 'Travanj', 'Svibanj', 'Lipanj',
      'Srpanj', 'Kolovoz', 'Rujan', 'Listopad', 'Studeni', 'Prosinac',
    ];
    return '${months[_focusedMonth.month]} ${_focusedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top bar ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kalendar',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.textPrimary)),
                    // Month navigator
                    Row(
                      children: [
                        _NavButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: _previousMonth),
                        const SizedBox(width: AppSpacing.xs),
                        Text(_monthLabel,
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: AppSpacing.xs),
                        _NavButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: _nextMonth),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Calendar grid ──────────────────────────────────────────
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
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _WeekdayHeader(),
                      const SizedBox(height: AppSpacing.sm),
                      _CalendarGrid(
                        focusedMonth: _focusedMonth,
                        selectedDay: _selectedDay,
                        dots: _dots,
                        onDayTap: (day) =>
                            setState(() => _selectedDay = day),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),

            // ── "OBVEZE U SVIBNJU" label ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                child: Text(
                  'OBVEZE U ${_monthLabel.toUpperCase()}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // ── Obligation list ────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _obligations[index];
                  final isLast = index == _obligations.length - 1;
                  return _CalendarObligationItem(
                      data: item, isLast: isLast);
                },
                childCount: _obligations.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Weekday header ────────────────────────────────────────────────────────────

class _WeekdayHeader extends StatelessWidget {
  static const _days = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: _days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        )),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

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
    // Monday=0 offset
    int startOffset = firstDay.weekday - 1;
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final prevMonthDays =
        DateTime(focusedMonth.year, focusedMonth.month, 0).day;

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
                // Prethodni mjesec
                final prevDay = prevMonthDays - startOffset + cellIndex + 1;
                return Expanded(
                  child: _DayCell(
                      day: prevDay, isCurrentMonth: false, dots: const []),
                );
              } else if (dayNumber > daysInMonth) {
                // Sljedeći mjesec
                final nextDay = dayNumber - daysInMonth;
                return Expanded(
                  child: _DayCell(
                      day: nextDay, isCurrentMonth: false, dots: const []),
                );
              } else {
                final isSelected = selectedDay?.day == dayNumber &&
                    selectedDay?.month == focusedMonth.month &&
                    selectedDay?.year == focusedMonth.year;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDayTap(DateTime(
                        focusedMonth.year, focusedMonth.month, dayNumber)),
                    child: _DayCell(
                      day: dayNumber,
                      isCurrentMonth: true,
                      isSelected: isSelected,
                      dots: dots[dayNumber] ?? [],
                    ),
                  ),
                );
              }
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
                ? BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Center(
              child: Text(
                '$day',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
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
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: dots
                .take(2)
                .map((c) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                          color: isSelected ? Colors.white70 : c,
                          shape: BoxShape.circle),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Obligation row (calendar style) ──────────────────────────────────────────

class _ObligationData {
  final String title;
  final String date;
  final String amount;
  final Color amountColor;

  const _ObligationData({
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
  });
}

class _CalendarObligationItem extends StatelessWidget {
  final _ObligationData data;
  final bool isLast;

  const _CalendarObligationItem(
      {required this.data, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, isLast ? 0 : AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: data.amountColor == const Color(0xFFEF4444)
                  ? AppColors.danger
                  : data.amountColor == const Color(0xFF6B7280)
                      ? AppColors.textSecondary.withOpacity(0.4)
                      : AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Title
          Expanded(
            child: Text(data.title,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500)),
          ),

          // Date
          Text(data.date,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppSpacing.md),

          // Amount
          Text(data.amount,
              style: AppTextStyles.body.copyWith(
                  color: data.amountColor,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────────────────────────────

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