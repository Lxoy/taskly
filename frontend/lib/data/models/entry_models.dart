// ── Enums (moraju matchati backend Data.Enums) ────────────────────────────────

enum EntryPriority { low, medium, high }

enum EntryRecurrenceType { once, daily, weekly, monthly, yearly }

// ── Request models ────────────────────────────────────────────────────────────

class CreateEntryRequest {
  final int? categoryId;
  final String title;
  final String? description;
  final double? amount;
  final EntryPriority priority;
  final EntryRecurrenceType recurrenceType;
  final int recurrenceInterval;
  final DateTime scheduledDate;
  final DateTime? recurrenceEndDate;

  const CreateEntryRequest({
    this.categoryId,
    required this.title,
    this.description,
    this.amount,
    required this.priority,
    required this.recurrenceType,
    this.recurrenceInterval = 1,
    required this.scheduledDate,
    this.recurrenceEndDate,
  });

  Map<String, dynamic> toJson() => {
        if (categoryId != null) 'categoryId': categoryId,
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (amount != null) 'amount': amount,
        'priority': priority.index,           // 0=Low, 1=Medium, 2=High
        'recurrenceType': recurrenceType.index, // 0=Once, 1=Daily, 2=Weekly, 3=Monthly, 4=Yearly
        'recurrenceInterval': recurrenceInterval,
        'scheduledDate': scheduledDate.toUtc().toIso8601String(),
        if (recurrenceEndDate != null)
          'recurrenceEndDate': recurrenceEndDate!.toUtc().toIso8601String(),
      };
}

class UpdateEntryRequest {
  final int? categoryId;
  final String title;
  final String? description;
  final double? amount;
  final EntryPriority priority;
  final EntryRecurrenceType recurrenceType;
  final int recurrenceInterval;
  final DateTime scheduledDate;
  final DateTime? recurrenceEndDate;

  const UpdateEntryRequest({
    this.categoryId,
    required this.title,
    this.description,
    this.amount,
    required this.priority,
    required this.recurrenceType,
    this.recurrenceInterval = 1,
    required this.scheduledDate,
    this.recurrenceEndDate,
  });

  Map<String, dynamic> toJson() => {
        if (categoryId != null) 'categoryId': categoryId,
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (amount != null) 'amount': amount,
        'priority': priority.index,
        'recurrenceType': recurrenceType.index,
        'recurrenceInterval': recurrenceInterval,
        'scheduledDate': scheduledDate.toUtc().toIso8601String(),
        if (recurrenceEndDate != null)
          'recurrenceEndDate': recurrenceEndDate!.toUtc().toIso8601String(),
      };
}

// ── Result wrapper ────────────────────────────────────────────────────────────

sealed class EntryResult {
  const EntryResult();
}

class EntrySuccess extends EntryResult {
  const EntrySuccess();
}

class EntryFailure extends EntryResult {
  final String message;
  const EntryFailure(this.message);
}