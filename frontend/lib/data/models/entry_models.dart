// ── Enums (match backend Data.Enums: 1-based values) ─────────────────────────

enum EntryPriority { low, medium, high }

enum EntryRecurrenceType { once, daily, weekly, monthly, yearly }

int _enumToBackend(Enum value) => value.index + 1;

T _enumFromBackend<T extends Enum>(List<T> values, dynamic raw) {
  final int value = raw is int ? raw : int.parse(raw.toString());
  return values[value - 1];
}

DateTime _parseDate(dynamic value) => DateTime.parse(value as String).toLocal();
String _dateToJson(DateTime value) => value.toUtc().toIso8601String();

// ── Request models ────────────────────────────────────────────────────────────

class CreateEntryRequest {
  final int? categoryId;
  final String title;
  final String? description;
  final double? amount;
  final EntryPriority priority;
  final EntryRecurrenceType recurrenceType;
  final int recurrenceInterval;
  final int? recurrenceDaysMask;
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
    this.recurrenceDaysMask,
    required this.scheduledDate,
    this.recurrenceEndDate,
  });

  Map<String, dynamic> toJson() => {
        if (categoryId != null) 'categoryId': categoryId,
        'title': title,
        if (description != null && description!.isNotEmpty) 'description': description,
        if (amount != null) 'amount': amount,
        'priority': _enumToBackend(priority),
        'recurrenceType': _enumToBackend(recurrenceType),
        'recurrenceInterval': recurrenceInterval,
        if (recurrenceDaysMask != null) 'recurrenceDaysMask': recurrenceDaysMask,
        'scheduledDate': _dateToJson(scheduledDate),
        if (recurrenceEndDate != null) 'recurrenceEndDate': _dateToJson(recurrenceEndDate!),
      };
}

class UpdateEntryRequest {
  final int? categoryId;
  final String? title;
  final String? description;
  final double? amount;
  final EntryPriority? priority;
  final EntryRecurrenceType? recurrenceType;
  final int? recurrenceInterval;
  final int? recurrenceDaysMask;
  final DateTime? scheduledDate;
  final DateTime? recurrenceEndDate;

  const UpdateEntryRequest({
    this.categoryId,
    this.title,
    this.description,
    this.amount,
    this.priority,
    this.recurrenceType,
    this.recurrenceInterval,
    this.recurrenceDaysMask,
    this.scheduledDate,
    this.recurrenceEndDate,
  });

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        if (title != null && title!.isNotEmpty) 'title': title,
        if (description != null) 'description': description,
        if (amount != null) 'amount': amount,
        if (priority != null) 'priority': _enumToBackend(priority!),
        if (recurrenceType != null) 'recurrenceType': _enumToBackend(recurrenceType!),
        if (recurrenceInterval != null) 'recurrenceInterval': recurrenceInterval,
        if (recurrenceDaysMask != null) 'recurrenceDaysMask': recurrenceDaysMask,
        if (scheduledDate != null) 'scheduledDate': _dateToJson(scheduledDate!),
        if (recurrenceEndDate != null) 'recurrenceEndDate': _dateToJson(recurrenceEndDate!),
      };
}

class UpdateEntryThisAndFutureRequest extends UpdateEntryRequest {
  final DateTime effectiveDate;

  const UpdateEntryThisAndFutureRequest({
    required this.effectiveDate,
    super.categoryId,
    super.title,
    super.description,
    super.amount,
    super.priority,
    super.recurrenceType,
    super.recurrenceInterval,
    super.recurrenceDaysMask,
    super.scheduledDate,
    super.recurrenceEndDate,
  });

  @override
  Map<String, dynamic> toJson() => {
        'effectiveDate': _dateToJson(effectiveDate),
        ...super.toJson(),
      };
}

class CreateEntryAnomalyRequest {
  final DateTime occurrenceDate;
  final DateTime? newOccurrenceDate;
  final String? title;
  final String? description;
  final double? amount;
  final EntryPriority? priority;
  final int? categoryId;

  const CreateEntryAnomalyRequest({
    required this.occurrenceDate,
    this.newOccurrenceDate,
    this.title,
    this.description,
    this.amount,
    this.priority,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
        'occurrenceDate': _dateToJson(occurrenceDate),
        if (newOccurrenceDate != null) 'newOccurrenceDate': _dateToJson(newOccurrenceDate!),
        if (title != null && title!.isNotEmpty) 'title': title,
        if (description != null) 'description': description,
        if (amount != null) 'amount': amount,
        if (priority != null) 'priority': _enumToBackend(priority!),
        'categoryId': categoryId,
      };
}

class EditEntryAnomalyRequest {
  final DateTime? occurrenceDate;
  final DateTime? newOccurrenceDate;
  final String? title;
  final String? description;
  final double? amount;
  final EntryPriority? priority;
  final int? categoryId;

  const EditEntryAnomalyRequest({
    this.occurrenceDate,
    this.newOccurrenceDate,
    this.title,
    this.description,
    this.amount,
    this.priority,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
        if (occurrenceDate != null) 'occurrenceDate': _dateToJson(occurrenceDate!),
        if (newOccurrenceDate != null) 'newOccurrenceDate': _dateToJson(newOccurrenceDate!),
        if (title != null && title!.isNotEmpty) 'title': title,
        if (description != null) 'description': description,
        if (amount != null) 'amount': amount,
        if (priority != null) 'priority': _enumToBackend(priority!),
        'categoryId': categoryId,
      };
}

// ── Occurrence list models ────────────────────────────────────────────────────

class EntryOccurrence {
  final int entryId;
  final int? anomalyId;
  final DateTime occurrenceDate;
  final String title;
  final String? description;
  final double? amount;
  final EntryPriority priority;
  final int? categoryId;

  const EntryOccurrence({
    required this.entryId,
    this.anomalyId,
    required this.occurrenceDate,
    required this.title,
    this.description,
    this.amount,
    required this.priority,
    this.categoryId,
  });

  factory EntryOccurrence.fromJson(Map<String, dynamic> json) {
    return EntryOccurrence(
      entryId: json['entryId'] as int,
      anomalyId: json['anomalyId'] as int?,
      occurrenceDate: _parseDate(json['occurrenceDate']),
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      priority: _enumFromBackend(EntryPriority.values, json['priority']),
      categoryId: json['categoryId'] as int?,
    );
  }
}

// ── Detail models ─────────────────────────────────────────────────────────────

abstract interface class OccurrenceDetails {
  int get entryId;
  int? get anomalyId;
  String get title;
  String? get description;
  double? get amount;
  EntryPriority get priority;
  int? get categoryId;
  DateTime get displayDate;
}

class EntryDetails implements OccurrenceDetails {
  final int id;
  @override
  int get entryId => id;
  @override
  int? get anomalyId => null;

  @override
  final int? categoryId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final double? amount;
  @override
  final EntryPriority priority;
  final EntryRecurrenceType recurrenceType;
  final int recurrenceInterval;
  final int? recurrenceDaysMask;
  final DateTime scheduledDate;
  final DateTime? recurrenceEndDate;

  @override
  DateTime get displayDate => scheduledDate;

  const EntryDetails({
    required this.id,
    this.categoryId,
    required this.title,
    this.description,
    this.amount,
    required this.priority,
    required this.recurrenceType,
    required this.recurrenceInterval,
    this.recurrenceDaysMask,
    required this.scheduledDate,
    this.recurrenceEndDate,
  });

  factory EntryDetails.fromJson(Map<String, dynamic> json) {
    return EntryDetails(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      priority: _enumFromBackend(EntryPriority.values, json['priority']),
      recurrenceType: _enumFromBackend(EntryRecurrenceType.values, json['recurrenceType']),
      recurrenceInterval: json['recurrenceInterval'] as int,
      recurrenceDaysMask: json['recurrenceDaysMask'] as int?,
      scheduledDate: _parseDate(json['scheduledDate']),
      recurrenceEndDate: json['recurrenceEndDate'] != null ? _parseDate(json['recurrenceEndDate']) : null,
    );
  }
}

class AnomalyDetails implements OccurrenceDetails {
  final int id;
  @override
  final int entryId;
  @override
  int? get anomalyId => id;
  final DateTime occurrenceDate;
  final DateTime? newOccurrenceDate;

  @override
  final String title;
  @override
  final String? description;
  @override
  final double? amount;
  @override
  final EntryPriority priority;
  @override
  final int? categoryId;

  @override
  DateTime get displayDate => newOccurrenceDate ?? occurrenceDate;

  const AnomalyDetails({
    required this.id,
    required this.entryId,
    required this.occurrenceDate,
    this.newOccurrenceDate,
    required this.title,
    this.description,
    this.amount,
    required this.priority,
    this.categoryId,
  });

  factory AnomalyDetails.fromJson(Map<String, dynamic> json) {
    return AnomalyDetails(
      id: json['id'] as int,
      entryId: json['entryId'] as int,
      occurrenceDate: _parseDate(json['occurrenceDate']),
      newOccurrenceDate: json['newOccurrenceDate'] != null ? _parseDate(json['newOccurrenceDate']) : null,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      priority: _enumFromBackend(EntryPriority.values, json['priority']),
      categoryId: json['categoryId'] as int?,
    );
  }
}

// ── Result wrappers ───────────────────────────────────────────────────────────

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

sealed class EntryDetailsResult {
  const EntryDetailsResult();
}

class EntryDetailsSuccess extends EntryDetailsResult {
  final OccurrenceDetails details;
  const EntryDetailsSuccess(this.details);
}

class EntryDetailsFailure extends EntryDetailsResult {
  final String message;
  const EntryDetailsFailure(this.message);
}

sealed class EntryOccurrencesResult {
  const EntryOccurrencesResult();
}

class EntryOccurrencesSuccess extends EntryOccurrencesResult {
  final List<EntryOccurrence> occurrences;
  const EntryOccurrencesSuccess(this.occurrences);
}

class EntryOccurrencesFailure extends EntryOccurrencesResult {
  final String message;
  const EntryOccurrencesFailure(this.message);
}
