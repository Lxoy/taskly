import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/category_models.dart';
import 'package:frontend/domain/repositories/category_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoriesFetchRequested extends CategoryEvent {
  const CategoriesFetchRequested();
}

class CategoryCreateRequested extends CategoryEvent {
  final String name;
  final String color;
  final String icon;
  const CategoryCreateRequested({
    required this.name,
    required this.color,
    required this.icon,
  });
  @override
  List<Object?> get props => [name, color, icon];
}

class CategoryUpdateRequested extends CategoryEvent {
  final int id;
  final String name;
  final String color;
  final String icon;
  const CategoryUpdateRequested({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
  @override
  List<Object?> get props => [id, name, color, icon];
}

class CategoryDeleteRequested extends CategoryEvent {
  final int id;
  const CategoryDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryMutating extends CategoryState {
  final List<Category> categories;
  const CategoryMutating(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  const CategoryLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;
  final List<Category> categories;
  const CategoryError(this.message, {this.categories = const []});
  @override
  List<Object?> get props => [message, categories];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repo;

  CategoryBloc(this._repo) : super(const CategoryInitial()) {
    on<CategoriesFetchRequested>(_onFetch);
    on<CategoryCreateRequested>(_onCreate);
    on<CategoryUpdateRequested>(_onUpdate);
    on<CategoryDeleteRequested>(_onDelete);
  }

  List<Category> get _currentList => switch (state) {
        CategoryLoaded(:final categories)   => categories,
        CategoryMutating(:final categories) => categories,
        CategoryError(:final categories)    => categories,
        _                                   => const [],
      };

  Future<void> _onFetch(
    CategoriesFetchRequested _,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final result = await _repo.getCategories();
    emit(switch (result) {
      CategorySuccess(:final data) => CategoryLoaded(data),
      CategoryFailure(:final message) => CategoryError(message),
    });
  }

  Future<void> _onCreate(
    CategoryCreateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final current = _currentList;
    emit(CategoryMutating(current));

    final result = await _repo.createCategory(
      CreateCategoryRequest(
          name: event.name, color: event.color, icon: event.icon),
    );

    switch (result) {
      case CategorySuccess():
        final fetched = await _repo.getCategories();
        emit(switch (fetched) {
          CategorySuccess(:final data) => CategoryLoaded(data),
          CategoryFailure(:final message) =>
            CategoryError(message, categories: current),
        });
      case CategoryFailure(:final message):
        emit(CategoryError(message, categories: current));
    }
  }

  Future<void> _onUpdate(
    CategoryUpdateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final current = _currentList;
    emit(CategoryMutating(current));

    final result = await _repo.updateCategory(
      event.id,
      UpdateCategoryRequest(
          name: event.name, color: event.color, icon: event.icon),
    );

    switch (result) {
      case CategorySuccess():
        final updated = current
            .map((c) => c.id == event.id
                ? Category(
                    id: c.id,
                    name: event.name,
                    color: event.color,
                    icon: event.icon)
                : c)
            .toList();
        emit(CategoryLoaded(updated));
      case CategoryFailure(:final message):
        emit(CategoryError(message, categories: current));
    }
  }

  Future<void> _onDelete(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final current = _currentList;
    emit(CategoryMutating(current));

    final result = await _repo.deleteCategory(event.id);

    emit(switch (result) {
      CategorySuccess() =>
        CategoryLoaded(current.where((c) => c.id != event.id).toList()),
      CategoryFailure(:final message) =>
        CategoryError(message, categories: current),
    });
  }
}