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

class EntryUpdateAllRequested extends EntryEvent {
  final int entryId;
  final UpdateEntryRequest request;
  const EntryUpdateAllRequested({required this.entryId, required this.request});
  @override
  List<Object?> get props => [entryId, request];
}

class EntryUpdateThisAndFutureRequested extends EntryEvent {
  final int entryId;
  final UpdateEntryThisAndFutureRequest request;
  const EntryUpdateThisAndFutureRequested({required this.entryId, required this.request});
  @override
  List<Object?> get props => [entryId, request];
}

class EntryDeleteRequested extends EntryEvent {
  final int entryId;
  final DateTime effectiveDate;
  const EntryDeleteRequested({required this.entryId, required this.effectiveDate});
  @override
  List<Object?> get props => [entryId, effectiveDate];
}

class EntryDeleteAllRequested extends EntryEvent {
  final int entryId;
  const EntryDeleteAllRequested(this.entryId);
  @override
  List<Object?> get props => [entryId];
}

class EntryDeleteFutureRequested extends EntryEvent {
  final int entryId;
  final DateTime effectiveDate;
  const EntryDeleteFutureRequested({required this.entryId, required this.effectiveDate});
  @override
  List<Object?> get props => [entryId, effectiveDate];
}

class EntryAnomalyCreateRequested extends EntryEvent {
  final int entryId;
  final CreateEntryAnomalyRequest request;
  const EntryAnomalyCreateRequested({required this.entryId, required this.request});
  @override
  List<Object?> get props => [entryId, request];
}

class EntryAnomalyEditRequested extends EntryEvent {
  final int anomalyId;
  final EditEntryAnomalyRequest request;
  const EntryAnomalyEditRequested({required this.anomalyId, required this.request});
  @override
  List<Object?> get props => [anomalyId, request];
}

class EntryAnomalyDeleteRequested extends EntryEvent {
  final int anomalyId;
  const EntryAnomalyDeleteRequested(this.anomalyId);
  @override
  List<Object?> get props => [anomalyId];
}

class EntryDetailsRequested extends EntryEvent {
  final int entryId;
  const EntryDetailsRequested(this.entryId);
  @override
  List<Object?> get props => [entryId];
}

class EntryAnomalyDetailsRequested extends EntryEvent {
  final int anomalyId;
  const EntryAnomalyDetailsRequested(this.anomalyId);
  @override
  List<Object?> get props => [anomalyId];
}

class EntryMonthOccurrencesRequested extends EntryEvent {
  final int year;
  final int month;
  const EntryMonthOccurrencesRequested({required this.year, required this.month});
  @override
  List<Object?> get props => [year, month];
}

class EntryDayOccurrencesRequested extends EntryEvent {
  final int year;
  final int month;
  final int day;
  const EntryDayOccurrencesRequested({required this.year, required this.month, required this.day});
  @override
  List<Object?> get props => [year, month, day];
}

class EntryReset extends EntryEvent {
  const EntryReset();
}

// ── Backward compatibility aliases ───────────────────────────────────────────

class EntryUpdateRequested extends EntryUpdateAllRequested {
  const EntryUpdateRequested({required int id, required UpdateEntryRequest request})
      : super(entryId: id, request: request);
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

class EntryDetailsLoaded extends EntryState {
  final OccurrenceDetails details;
  const EntryDetailsLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class EntryOccurrencesLoaded extends EntryState {
  final List<EntryOccurrence> occurrences;
  const EntryOccurrencesLoaded(this.occurrences);
  @override
  List<Object?> get props => [occurrences];
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
    on<EntryUpdateAllRequested>(_onUpdateAll);
    on<EntryUpdateThisAndFutureRequested>(_onUpdateThisAndFuture);
    on<EntryDeleteRequested>(_onDeleteOne);
    on<EntryDeleteAllRequested>(_onDeleteAll);
    on<EntryDeleteFutureRequested>(_onDeleteFuture);
    on<EntryAnomalyCreateRequested>(_onCreateAnomaly);
    on<EntryAnomalyEditRequested>(_onEditAnomaly);
    on<EntryAnomalyDeleteRequested>(_onDeleteAnomaly);
    on<EntryDetailsRequested>(_onGetEntryDetails);
    on<EntryAnomalyDetailsRequested>(_onGetAnomalyDetails);
    on<EntryMonthOccurrencesRequested>(_onGetMonthOccurrences);
    on<EntryDayOccurrencesRequested>(_onGetDayOccurrences);
    on<EntryReset>((_, emit) => emit(const EntryInitial()));
  }

  Future<void> _onCreate(EntryCreateRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.createEntry(event.request);
    emit(switch (result) {
      EntrySuccess() => const EntryCreated(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onUpdateAll(EntryUpdateAllRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.updateEntryAll(event.entryId, event.request);
    emit(switch (result) {
      EntrySuccess() => const EntryUpdated(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onUpdateThisAndFuture(
    EntryUpdateThisAndFutureRequested event,
    Emitter<EntryState> emit,
  ) async {
    emit(const EntryLoading());
    final result = await _repo.updateEntryThisAndFuture(event.entryId, event.request);
    emit(switch (result) {
      EntrySuccess() => const EntryUpdated(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onDeleteOne(EntryDeleteRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.deleteEntry(
      entryId: event.entryId,
      effectiveDate: event.effectiveDate,
    );
    emit(switch (result) {
      EntrySuccess() => const EntryDeleted(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onDeleteAll(EntryDeleteAllRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.deleteEntryAll(event.entryId);
    emit(switch (result) {
      EntrySuccess() => const EntryDeleted(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onDeleteFuture(EntryDeleteFutureRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.deleteEntryFuture(
      entryId: event.entryId,
      effectiveDate: event.effectiveDate,
    );
    emit(switch (result) {
      EntrySuccess() => const EntryDeleted(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onCreateAnomaly(EntryAnomalyCreateRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.createAnomaly(entryId: event.entryId, request: event.request);
    emit(switch (result) {
      EntrySuccess() => const EntryUpdated(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onEditAnomaly(EntryAnomalyEditRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.editAnomaly(anomalyId: event.anomalyId, request: event.request);
    emit(switch (result) {
      EntrySuccess() => const EntryUpdated(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onDeleteAnomaly(EntryAnomalyDeleteRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.deleteAnomaly(event.anomalyId);
    emit(switch (result) {
      EntrySuccess() => const EntryDeleted(),
      EntryFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onGetEntryDetails(EntryDetailsRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.getEntry(event.entryId);
    emit(switch (result) {
      EntryDetailsSuccess(:final details) => EntryDetailsLoaded(details),
      EntryDetailsFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onGetAnomalyDetails(EntryAnomalyDetailsRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.getAnomaly(event.anomalyId);
    emit(switch (result) {
      EntryDetailsSuccess(:final details) => EntryDetailsLoaded(details),
      EntryDetailsFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onGetMonthOccurrences(EntryMonthOccurrencesRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.getOccurrencesForMonth(year: event.year, month: event.month);
    emit(switch (result) {
      EntryOccurrencesSuccess(:final occurrences) => EntryOccurrencesLoaded(occurrences),
      EntryOccurrencesFailure(:final message) => EntryError(message),
    });
  }

  Future<void> _onGetDayOccurrences(EntryDayOccurrencesRequested event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    final result = await _repo.getOccurrencesForDay(
      year: event.year,
      month: event.month,
      day: event.day,
    );
    emit(switch (result) {
      EntryOccurrencesSuccess(:final occurrences) => EntryOccurrencesLoaded(occurrences),
      EntryOccurrencesFailure(:final message) => EntryError(message),
    });
  }
}
