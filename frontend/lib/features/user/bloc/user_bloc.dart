import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/user_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/user_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class UserFetchRequested extends UserEvent {
  const UserFetchRequested();
}

class UserUpdateRequested extends UserEvent {
  final UpdateUserRequest request;
  const UserUpdateRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class UserPasswordUpdateRequested extends UserEvent {
  final UpdatePasswordRequest request;
  const UserPasswordUpdateRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class UserReset extends UserEvent {
  const UserReset();
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final GetUserDto user;
  const UserLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class UserUpdated extends UserState {
  final GetUserDto user;
  const UserUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

class UserPasswordUpdated extends UserState {
  const UserPasswordUpdated();
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repo;
  final ApiClient _apiClient;

  UserBloc(this._repo, this._apiClient) : super(const UserInitial()) {
    on<UserFetchRequested>(_onFetch);
    on<UserUpdateRequested>(_onUpdate);
    on<UserPasswordUpdateRequested>(_onPasswordUpdate);
    on<UserReset>((_, emit) => emit(const UserInitial()));
  }

  Future<void> _onFetch(
    UserFetchRequested _,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await _repo.getUser();
    emit(switch (result) {
      UserSuccess(:final data) => UserLoaded(data),
      UserFailure(:final message) => UserError(message),
    });
  }

  Future<void> _onUpdate(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await _repo.updateUser(event.request);
    switch (result) {
      case UserSuccess(:final data):
        if (data != null) await _apiClient.saveToken(data);
        // Build updated dto from request fields
        final updated = GetUserDto(
          firstName:   event.request.firstName,
          lastName:    event.request.lastName,
          username:    event.request.username,
          email:       event.request.email,
          phoneNumber: event.request.phoneNumber,
        );
        emit(UserUpdated(updated));
      case UserFailure(:final message):
        emit(UserError(message));
    }
  }

  Future<void> _onPasswordUpdate(
    UserPasswordUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await _repo.updatePassword(event.request);
    emit(switch (result) {
      UserSuccess() => const UserPasswordUpdated(),
      UserFailure(:final message) => UserError(message),
    });
  }
}