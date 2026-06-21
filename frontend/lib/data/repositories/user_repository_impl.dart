import 'package:dio/dio.dart';
import 'package:frontend/data/models/user_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient _client;

  const UserRepositoryImpl(this._client);

  @override
  Future<UserResult<GetUserDto>> getUser() async {
    try {
      final response = await _client.dio.get('/api/user');
      final dto = GetUserDto.fromJson(response.data as Map<String, dynamic>);
      return UserSuccess(dto);
    } on DioException catch (e) {
      return UserFailure(_msg(e, 'Failed to load profile.'));
    } catch (_) {
      return const UserFailure('Unexpected error.');
    }
  }

  @override
  Future<UserResult<String?>> updateUser(UpdateUserRequest request) async {
    try {
      final response = await _client.dio.put(
        '/api/user',
        data: request.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;

      return UserSuccess(token);
    } on DioException catch (e) {
      return UserFailure(_msg(e, 'Failed to update profile.'));
    } catch (_) {
      return const UserFailure('Unexpected error.');
    }
  }

  @override
  Future<UserResult<void>> updatePassword(UpdatePasswordRequest request) async {
    try {
      await _client.dio.put('/api/user/password', data: request.toJson());
      return const UserSuccess(null);
    } on DioException catch (e) {
      return UserFailure(_msg(e, 'Failed to update password.'));
    } catch (_) {
      return const UserFailure('Unexpected error.');
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
      _ => fallback,
    };
  }
}
