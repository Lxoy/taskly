// ─────────────────────────────────────────────
// REQUEST models
// ─────────────────────────────────────────────

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String email;
  final String username;
  final String password;

  const RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'password': password,
      };
}

// ─────────────────────────────────────────────
// RESPONSE models
// ─────────────────────────────────────────────

class AuthResponse {
  final String token;

  const AuthResponse({required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(token: json['token'] as String);
  }
}

// ─────────────────────────────────────────────
// RESULT wrapper
// ─────────────────────────────────────────────

sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final AuthResponse data;
  const AuthSuccess(this.data);
}

class AuthFailure extends AuthResult {
  final String message;
  final int? statusCode;
  const AuthFailure(this.message, {this.statusCode});
}