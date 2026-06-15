class HomeData {
  final double totalMoneySpentThisMonth;
  final String month;
  final String year;
  final int totalEntriesFinishedThisMonth;
  final int totalEntriesScheduledForThisMonth;
  final List<HomeScheduleEntry> scheduleEntries;

  const HomeData({
    required this.totalMoneySpentThisMonth,
    required this.month,
    required this.year,
    required this.totalEntriesFinishedThisMonth,
    required this.totalEntriesScheduledForThisMonth,
    required this.scheduleEntries,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      totalMoneySpentThisMonth: (json['totalMoneySpentThisMonth'] as num).toDouble(),
      month: json['month'] as String,
      year: json['year'] as String,
      totalEntriesFinishedThisMonth: json['totalEntriesFinishedThisMonth'] as int,
      totalEntriesScheduledForThisMonth: json['totalEntriesScheduledForThisMonth'] as int,
      scheduleEntries: (json['scheduleEntries'] as List<dynamic>)
          .map((e) => HomeScheduleEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HomeScheduleEntry {
  final int id;
  final String title;
  final int daysUntilDue;
  final DateTime? dueDate;
  final double? amount;

  const HomeScheduleEntry({
    required this.id,
    required this.title,
    required this.daysUntilDue,
    this.dueDate,
    this.amount,
  });

  factory HomeScheduleEntry.fromJson(Map<String, dynamic> json) {
    return HomeScheduleEntry(
      id: json['id'] as int,
      title: json['title'] as String,
      daysUntilDue: json['daysUntilDue'] as int,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
    );
  }
}

// ── Result wrapper ────────────────────────────────────────────────────────────

sealed class HomeResult {
  const HomeResult();
}

class HomeSuccess extends HomeResult {
  final HomeData data;
  const HomeSuccess(this.data);
}

class HomeFailure extends HomeResult {
  final String message;
  const HomeFailure(this.message);
}