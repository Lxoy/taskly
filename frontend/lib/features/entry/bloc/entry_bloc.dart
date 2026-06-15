import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/entry_models.dart';
import 'package:frontend/domain/repositories/entry_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class EntryEvent extends Equatable {
  const EntryEvent();
  @override
  List<Object?> get props => [];
}

class EntryCreateRequested extends EntryEvent {
  final CreateEntryRequest request;
  const EntryCreateRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class EntryUpdateRequested extends EntryEvent {
  final int id;
  final UpdateEntryRequest request;
  const EntryUpdateRequested({required this.id, required this.request});
  @override
  List<Object?> get props => [id, request];
}

class EntryDeleteRequested extends EntryEvent {
  final int id;
  const EntryDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class EntryReset extends EntryEvent {
  const EntryReset();
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class EntryState extends Equatable {
  const EntryState();
  @override
  List<Object?> get props => [];
}

class EntryInitial extends EntryState {
  const EntryInitial();
}

class EntryLoading extends EntryState {
  const EntryLoading();
}

class EntryCreated extends EntryState {
  const EntryCreated();
}

class EntryUpdated extends EntryState {
  const EntryUpdated();
}

class EntryDeleted extends EntryState {
  const EntryDeleted();
}

class EntryError extends EntryState {
  final String message;
  const EntryError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class EntryBloc extends Bloc<EntryEvent, EntryState> {
  final EntryRepository _repo;

  EntryBloc(this._repo) : super(const EntryInitial()) {
    on<EntryCreateRequested>(_onCreate);
    on<EntryUpdateRequested>(_onUpdate);
    on<EntryDeleteRequested>(_onDelete);
    on<EntryReset>((_, emit) => emit(const EntryInitial()));
  }

  Future<void> _onCreate(
    EntryCreateRequested event,
    Emitter<EntryState> emit,
  ) async {
    emit(const EntryLoading());
    final result = await _repo.createEntry(event.request);
    emit(switch (result) {
      EntrySuccess() => const EntryCreated(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onUpdate(
    EntryUpdateRequested event,
    Emitter<EntryState> emit,
  ) async {
    emit(const EntryLoading());
    final result = await _repo.updateEntry(event.id, event.request);
    emit(switch (result) {
      EntrySuccess() => const EntryUpdated(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onDelete(
    EntryDeleteRequested event,
    Emitter<EntryState> emit,
  ) async {
    emit(const EntryLoading());
    final result = await _repo.deleteEntry(event.id);
    emit(switch (result) {
      EntrySuccess() => const EntryDeleted(),
      EntryFailure(:final message) => EntryError(message),
    });
  }
}