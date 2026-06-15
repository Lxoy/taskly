// ─────────────────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/auth_models.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

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

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// ─────────────────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────────────────

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Početno stanje — korisnik nije prijavljen
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Request je u tijeku — prikaži loading indikator
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Uspješna prijava/registracija — token je spremljen
class AuthAuthenticated extends AuthState {
  final String token;
  const AuthAuthenticated(this.token);

  @override
  List<Object?> get props => [token];
}

/// Greška — prikaži poruku korisniku
class AuthError extends AuthState {
  final String message;
  final int? statusCode;

  const AuthError(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// ─────────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  // ── Login ─────────────────────────────────────────────────────
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

  // ── Register ──────────────────────────────────────────────────
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

  // ── Logout ────────────────────────────────────────────────────
  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInitial());
  }
}