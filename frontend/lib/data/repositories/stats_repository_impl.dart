import 'package:dio/dio.dart';
import 'package:frontend/data/models/stats_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final ApiClient _client;
  static const _basePath = '/api/stats';

  const StatsRepositoryImpl(this._client);

  @override
  Future<StatsResult> getStats() async {
    try {
      final res = await _client.dio.get(_basePath);
      return StatsSuccess(
        StatsData.fromJson(res.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return StatsFailure(_msg(e, 'Failed to load statistics.'));
    } catch (_) {
      return const StatsFailure('Unexpected error.');
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
