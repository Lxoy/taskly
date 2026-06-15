import 'package:dio/dio.dart';
import 'package:frontend/data/models/category_models.dart';
import 'package:frontend/data/network/api_client.dart';
import 'package:frontend/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ApiClient _client;
  static const _basePath = '/api/category';

  const CategoryRepositoryImpl(this._client);

  @override
  Future<CategoryResult<List<Category>>> getCategories() async {
    try {
      final response = await _client.dio.get(_basePath);
      final list = (response.data as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      return CategorySuccess(list);
    } on DioException catch (e) {
      return CategoryFailure(_msg(e, 'Failed to load categories.'));
    } catch (_) {
      return const CategoryFailure('Unexpected error.');
    }
  }

  @override
  Future<CategoryResult<void>> createCategory(
      CreateCategoryRequest request) async {
    try {
      await _client.dio.post(_basePath, data: request.toJson());
      return const CategorySuccess(null);
    } on DioException catch (e) {
      return CategoryFailure(_msg(e, 'Failed to create category.'));
    } catch (_) {
      return const CategoryFailure('Unexpected error.');
    }
  }

  @override
  Future<CategoryResult<void>> updateCategory(
      int id, UpdateCategoryRequest request) async {
    try {
      await _client.dio.put('$_basePath/$id', data: request.toJson());
      return const CategorySuccess(null);
    } on DioException catch (e) {
      return CategoryFailure(_msg(e, 'Failed to update category.'));
    } catch (_) {
      return const CategoryFailure('Unexpected error.');
    }
  }

  @override
  Future<CategoryResult<void>> deleteCategory(int id) async {
    try {
      await _client.dio.delete('$_basePath/$id');
      return const CategorySuccess(null);
    } on DioException catch (e) {
      return CategoryFailure(_msg(e, 'Failed to delete category.'));
    } catch (_) {
      return const CategoryFailure('Unexpected error.');
    }
  }

  String _msg(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return (data['message'] as String?) ?? fallback;
      }
    } catch (_) {}
    return switch (e.type) {
      DioExceptionType.connectionError   => 'No internet connection.',
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.receiveTimeout    => 'Server not responding.',
      _                                  => fallback,
    };
  }
}