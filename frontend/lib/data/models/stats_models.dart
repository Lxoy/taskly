class StatsData {
  final double totalSpentThisMonth;
  final double averageAmount;
  final int totalOccurrencesThisMonth;
  final int completedOccurrencesThisMonth;
  final int upcomingOccurrencesThisMonth;
  final String topCategoryName;
  final double topCategoryAmount;
  final List<MonthlySpending> monthlySpending;
  final List<CategorySpending> categorySpending;
  final PriorityOverview priorityOverview;
  final RecurrenceOverview recurrenceOverview;

  const StatsData({
    required this.totalSpentThisMonth,
    required this.averageAmount,
    required this.totalOccurrencesThisMonth,
    required this.completedOccurrencesThisMonth,
    required this.upcomingOccurrencesThisMonth,
    required this.topCategoryName,
    required this.topCategoryAmount,
    required this.monthlySpending,
    required this.categorySpending,
    required this.priorityOverview,
    required this.recurrenceOverview,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      totalSpentThisMonth: (json['totalSpentThisMonth'] as num? ?? 0).toDouble(),
      averageAmount: (json['averageAmount'] as num? ?? 0).toDouble(),
      totalOccurrencesThisMonth: json['totalOccurrencesThisMonth'] as int? ?? 0,
      completedOccurrencesThisMonth: json['completedOccurrencesThisMonth'] as int? ?? 0,
      upcomingOccurrencesThisMonth: json['upcomingOccurrencesThisMonth'] as int? ?? 0,
      topCategoryName: json['topCategoryName'] as String? ?? 'None',
      topCategoryAmount: (json['topCategoryAmount'] as num? ?? 0).toDouble(),
      monthlySpending: (json['monthlySpending'] as List<dynamic>? ?? const [])
          .map((e) => MonthlySpending.fromJson(e as Map<String, dynamic>))
          .toList(),
      categorySpending: (json['categorySpending'] as List<dynamic>? ?? const [])
          .map((e) => CategorySpending.fromJson(e as Map<String, dynamic>))
          .toList(),
      priorityOverview: PriorityOverview.fromJson(
        json['priorityOverview'] as Map<String, dynamic>? ?? const {},
      ),
      recurrenceOverview: RecurrenceOverview.fromJson(
        json['recurrenceOverview'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class MonthlySpending {
  final String month;
  final double amount;

  const MonthlySpending({required this.month, required this.amount});

  factory MonthlySpending.fromJson(Map<String, dynamic> json) {
    return MonthlySpending(
      month: json['month'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
    );
  }
}

class CategorySpending {
  final int? categoryId;
  final String categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final double amount;

  const CategorySpending({
    this.categoryId,
    required this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    required this.amount,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String? ?? 'Uncategorized',
      categoryColor: json['categoryColor'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      amount: (json['amount'] as num? ?? 0).toDouble(),
    );
  }
}

class PriorityOverview {
  final int low;
  final int medium;
  final int high;

  const PriorityOverview({
    required this.low,
    required this.medium,
    required this.high,
  });

  int get total => low + medium + high;

  factory PriorityOverview.fromJson(Map<String, dynamic> json) {
    return PriorityOverview(
      low: json['low'] as int? ?? 0,
      medium: json['medium'] as int? ?? 0,
      high: json['high'] as int? ?? 0,
    );
  }
}

class RecurrenceOverview {
  final int oneTime;
  final int recurring;

  const RecurrenceOverview({
    required this.oneTime,
    required this.recurring,
  });

  int get total => oneTime + recurring;

  factory RecurrenceOverview.fromJson(Map<String, dynamic> json) {
    return RecurrenceOverview(
      oneTime: json['oneTime'] as int? ?? 0,
      recurring: json['recurring'] as int? ?? 0,
    );
  }
}

sealed class StatsResult {
  const StatsResult();
}

class StatsSuccess extends StatsResult {
  final StatsData data;
  const StatsSuccess(this.data);
}

class StatsFailure extends StatsResult {
  final String message;
  const StatsFailure(this.message);
}
