import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/home_models.dart';
import 'package:frontend/domain/repositories/home_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeFetchRequested extends HomeEvent {
  const HomeFetchRequested();
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final HomeData data;
  const HomeLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc(this._homeRepository) : super(const HomeInitial()) {
    on<HomeFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    HomeFetchRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await _homeRepository.getHomeData();

    switch (result) {
      case HomeSuccess(:final data):
        emit(HomeLoaded(data));
      case HomeFailure(:final message):
        emit(HomeError(message));
    }
  }
}