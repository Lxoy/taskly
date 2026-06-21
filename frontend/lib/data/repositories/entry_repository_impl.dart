import 'package:dio/dio.dart';
import 'package:frontend/data/models/entry_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/entry_repository.dart';

class EntryRepositoryImpl implements EntryRepository {
  final ApiClient _client;
  static const _basePath = '/api/entry';
  static const _anomalyPath = '/api/entry-anomaly';

  const EntryRepositoryImpl(this._client);

  @override
  Future<EntryResult> createEntry(CreateEntryRequest request) async {
    try {
      await _client.dio.post(_basePath, data: request.toJson());
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to create entry.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> updateEntryAll(
    int entryId,
    UpdateEntryRequest request,
  ) async {
    try {
      await _client.dio.put('$_basePath/$entryId/all', data: request.toJson());
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to update entry.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> updateEntryThisAndFuture(
    int entryId,
    UpdateEntryThisAndFutureRequest request,
  ) async {
    try {
      await _client.dio.put(
        '$_basePath/$entryId/split',
        data: request.toJson(),
      );
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to update future entries.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> deleteEntry({
    required int entryId,
    required DateTime effectiveDate,
  }) async {
    try {
      await _client.dio.delete(
        '$_basePath/$entryId',
        queryParameters: {
          'effectiveDate': effectiveDate.toUtc().toIso8601String(),
        },
      );
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to delete occurrence.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> deleteEntryAll(int entryId) async {
    try {
      await _client.dio.delete('$_basePath/$entryId/all');
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to delete entry.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> deleteEntryFuture({
    required int entryId,
    required DateTime effectiveDate,
  }) async {
    try {
      await _client.dio.delete(
        '$_basePath/$entryId/future',
        queryParameters: {
          'effectiveDate': effectiveDate.toUtc().toIso8601String(),
        },
      );
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to delete future entries.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> createAnomaly({
    required int entryId,
    required CreateEntryAnomalyRequest request,
  }) async {
    try {
      await _client.dio.post(
        '$_anomalyPath/$entryId/anomaly',
        data: request.toJson(),
      );

      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to edit occurrence.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> editAnomaly({
    required int anomalyId,
    required EditEntryAnomalyRequest request,
  }) async {
    try {
      await _client.dio.put(
        '$_anomalyPath/$anomalyId/anomaly',
        data: request.toJson(),
      );

      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to update occurrence.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> deleteAnomaly(int anomalyId) async {
    try {
      await _client.dio.delete('$_anomalyPath/$anomalyId/anomaly');

      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to delete occurrence.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryDetailsResult> getEntry(int entryId) async {
    try {
      final res = await _client.dio.get('$_basePath/$entryId');
      return EntryDetailsSuccess(
        EntryDetails.fromJson(res.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return EntryDetailsFailure(_msg(e, 'Failed to load entry.'));
    } catch (_) {
      return const EntryDetailsFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryDetailsResult> getAnomaly(int anomalyId) async {
    try {
      final res = await _client.dio.get('$_anomalyPath/$anomalyId');

      return EntryDetailsSuccess(
        AnomalyDetails.fromJson(res.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return EntryDetailsFailure(_msg(e, 'Failed to load occurrence.'));
    } catch (_) {
      return const EntryDetailsFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryOccurrencesResult> getOccurrencesForMonth({
    required int year,
    required int month,
  }) async {
    try {
      final res = await _client.dio.get(
        '$_basePath/occurrences/month',
        queryParameters: {'year': year, 'month': month},
      );
      final items = (res.data as List<dynamic>)
          .map((e) => EntryOccurrence.fromJson(e as Map<String, dynamic>))
          .toList();
      return EntryOccurrencesSuccess(items);
    } on DioException catch (e) {
      return EntryOccurrencesFailure(_msg(e, 'Failed to load occurrences.'));
    } catch (_) {
      return const EntryOccurrencesFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryOccurrencesResult> getOccurrencesForDay({
    required int year,
    required int month,
    required int day,
  }) async {
    try {
      final res = await _client.dio.get(
        '$_basePath/occurrences/day',
        queryParameters: {'year': year, 'month': month, 'day': day},
      );
      final items = (res.data as List<dynamic>)
          .map((e) => EntryOccurrence.fromJson(e as Map<String, dynamic>))
          .toList();
      return EntryOccurrencesSuccess(items);
    } on DioException catch (e) {
      return EntryOccurrencesFailure(
        _msg(e, 'Failed to load day occurrences.'),
      );
    } catch (_) {
      return const EntryOccurrencesFailure('Unexpected error.');
    }
  }

  String _msg(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return (data['message'] as String?) ?? fallback;
      }
    } catch (_) {}
    return switch (e.type) {
      DioExceptionType.connectionError => 'No internet connection.',
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.receiveTimeout => 'Server not responding.',
      _ => fallback,
    };
  }
}
