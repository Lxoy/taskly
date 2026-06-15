import 'package:dio/dio.dart';
import 'package:frontend/data/models/entry_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/entry_repository.dart';

class EntryRepositoryImpl implements EntryRepository {
  final ApiClient _client;
  static const _basePath = '/api/entry';

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
  Future<EntryResult> updateEntry(int id, UpdateEntryRequest request) async {
    try {
      await _client.dio.put('$_basePath/$id', data: request.toJson());
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to update entry.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
    }
  }

  @override
  Future<EntryResult> deleteEntry(int id) async {
    try {
      await _client.dio.delete('$_basePath/$id');
      return const EntrySuccess();
    } on DioException catch (e) {
      return EntryFailure(_msg(e, 'Failed to delete entry.'));
    } catch (_) {
      return const EntryFailure('Unexpected error.');
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
      DioExceptionType.connectionError   => 'No internet connection.',
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.receiveTimeout    => 'Server not responding.',
      _                                  => fallback,
    };
  }
}