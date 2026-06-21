import 'package:frontend/data/models/entry_models.dart';

abstract interface class EntryRepository {
  Future<EntryResult> createEntry(CreateEntryRequest request);

  Future<EntryResult> updateEntryAll(int entryId, UpdateEntryRequest request);

  Future<EntryResult> updateEntryThisAndFuture(
    int entryId,
    UpdateEntryThisAndFutureRequest request,
  );

  Future<EntryResult> deleteEntry({
    required int entryId,
    required DateTime effectiveDate,
  });

  Future<EntryResult> deleteEntryAll(int entryId);

  Future<EntryResult> deleteEntryFuture({
    required int entryId,
    required DateTime effectiveDate,
  });

  Future<EntryResult> createAnomaly({
    required int entryId,
    required CreateEntryAnomalyRequest request,
  });

  Future<EntryResult> editAnomaly({
    required int anomalyId,
    required EditEntryAnomalyRequest request,
  });

  Future<EntryResult> deleteAnomaly(int anomalyId);

  Future<EntryDetailsResult> getEntry(int entryId);

  Future<EntryDetailsResult> getAnomaly(int anomalyId);

  Future<EntryOccurrencesResult> getOccurrencesForMonth({
    required int year,
    required int month,
  });

  Future<EntryOccurrencesResult> getOccurrencesForDay({
    required int year,
    required int month,
    required int day,
  });
}
