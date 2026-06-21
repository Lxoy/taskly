import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/auth_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  const LoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String username;
  final String password;
  const RegisterSubmitted({
    required this.email,
    required this.username,
    required this.password,
  });
  @override
  List<Object?> get props => [email, username, password];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String token;
  const AuthAuthenticated(this.token);
  @override
  List<Object?> get props => [token];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final int? statusCode;
  const AuthError(this.message, {this.statusCode});
  @override
  List<Object?> get props => [message, statusCode];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  AuthBloc(this._authRepository, this._apiClient)
      : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  // ── Check token on startup ────────────────────────────────────────────────

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> _onLogin(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.login(
      LoginRequest(email: event.email, password: event.password),
    );
    switch (result) {
      case AuthSuccess(:final data):
        emit(AuthAuthenticated(data.token));
      case AuthFailure(:final message, :final statusCode):
        emit(AuthError(message, statusCode: statusCode));
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<void> _onRegister(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.register(
      RegisterRequest(
        email: event.email,
        username: event.username,
        password: event.password,
      ),
    );
    switch (result) {
      case AuthSuccess(:final data):
        emit(AuthAuthenticated(data.token));
      case AuthFailure(:final message, :final statusCode):
        emit(AuthError(message, statusCode: statusCode));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _apiClient.deleteToken();
    emit(const AuthUnauthenticated());
  }
}