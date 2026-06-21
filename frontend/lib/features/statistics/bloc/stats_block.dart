import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/stats_models.dart';
import 'package:frontend/domain/stats_repository.dart';

sealed class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

class StatsFetchRequested extends StatsEvent {
  const StatsFetchRequested();
}

sealed class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  final StatsData data;
  const StatsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsRepository _repository;

  StatsBloc(this._repository) : super(const StatsInitial()) {
    on<StatsFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    StatsFetchRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(const StatsLoading());

    final result = await _repository.getStats();

    emit(switch (result) {
      StatsSuccess(:final data) => StatsLoaded(data),
      StatsFailure(:final message) => StatsError(message),
    });
  }
}
