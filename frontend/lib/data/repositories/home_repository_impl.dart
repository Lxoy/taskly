import 'package:dio/dio.dart';
import 'package:frontend/data/models/home_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _client;

  static const _homePath = '/api/home';

  const HomeRepositoryImpl(this._client);

  @override
  Future<HomeResult> getHomeData() async {
    try {
      final response = await _client.dio.get(_homePath);
      final data = HomeData.fromJson(response.data as Map<String, dynamic>);
      return HomeSuccess(data);
    } on DioException catch (e) {
      return HomeFailure(_extractMessage(e));
    } catch (_) {
      return const HomeFailure('Neočekivana greška. Pokušaj ponovno.');
    }
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return (data['message'] as String?) ?? 'Greška pri dohvaćanju podataka.';
      }
    } catch (_) {}

    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'Vremensko ograničenje veze isteklo.',
      DioExceptionType.receiveTimeout    => 'Server ne odgovara.',
      DioExceptionType.connectionError   => 'Nema internetske veze.',
      _                                  => 'Greška pri dohvaćanju podataka.',
    };
  }
}