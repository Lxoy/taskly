import 'package:frontend/data/models/entry_models.dart';

abstract interface class EntryRepository {
  /// POST /api/entry
  Future<EntryResult> createEntry(CreateEntryRequest request);

  /// PUT /api/entry/{id}
  Future<EntryResult> updateEntry(int id, UpdateEntryRequest request);

  /// DELETE /api/entry/{id}
  Future<EntryResult> deleteEntry(int id);
}