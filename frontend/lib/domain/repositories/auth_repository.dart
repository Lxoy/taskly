import 'package:frontend/data/models/auth_models.dart';

abstract interface class AuthRepository {
  /// POST /api/auth/login
  Future<AuthResult> login(LoginRequest request);

  /// POST /api/auth/register
  Future<AuthResult> register(RegisterRequest request);
}