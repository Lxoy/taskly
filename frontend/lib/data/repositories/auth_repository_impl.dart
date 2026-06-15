import 'package:dio/dio.dart';
import 'package:frontend/data/models/auth_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _client;

  static const _loginPath    = '/api/auth/login';
  static const _registerPath = '/api/auth/register';

  const AuthRepositoryImpl(this._client);

  // ── POST /api/auth/login ──────────────────────────────────────────────
  @override
  Future<AuthResult> login(LoginRequest request) async {
    try {
      final response = await _client.dio.post(
        _loginPath,
        data: request.toJson(),
      );

      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);

      // Spremi token lokalno
      await _client.saveToken(auth.token);

      return AuthSuccess(auth);
    } on DioException catch (e) {
      return AuthFailure(
        _extractMessage(e, fallback: 'Pogrešan email ili lozinka.'),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return const AuthFailure('Neočekivana greška. Pokušaj ponovno.');
    }
  }

  // ── POST /api/auth/register ───────────────────────────────────────────
  @override
  Future<AuthResult> register(RegisterRequest request) async {
    try {
      final response = await _client.dio.post(
        _registerPath,
        data: request.toJson(),
      );

      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);

      // Automatska prijava nakon registracije — spremi token
      await _client.saveToken(auth.token);

      return AuthSuccess(auth);
    } on DioException catch (e) {
      return AuthFailure(
        _extractMessage(e, fallback: 'Registracija nije uspjela.'),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return const AuthFailure('Neočekivana greška. Pokušaj ponovno.');
    }
  }

  // ── Helper: izvuci poruku iz .NET BadRequest/Unauthorized odgovora ────
  // Backend vraća: { "message": "..." }
  String _extractMessage(DioException e, {required String fallback}) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // .NET controller vraća lowercase "message"
        return (data['message'] as String?) ?? fallback;
      }
    } catch (_) {}

    // Mrežne greške (nema interneta, timeout, itd.)
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'Vremensko ograničenje veze isteklo.',
      DioExceptionType.receiveTimeout    => 'Server ne odgovara.',
      DioExceptionType.connectionError   => 'Nema internetske veze.',
      _                                  => fallback,
    };
  }
}