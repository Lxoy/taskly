
import 'package:frontend/data/models/category_models.dart';

abstract interface class CategoryRepository {
  /// GET /api/category
  Future<CategoryResult<List<Category>>> getCategories();

  /// POST /api/category
  Future<CategoryResult<void>> createCategory(CreateCategoryRequest request);

  /// PUT /api/category/{id}
  Future<CategoryResult<void>> updateCategory(int id, UpdateCategoryRequest request);

  /// DELETE /api/category/{id}
  Future<CategoryResult<void>> deleteCategory(int id);
}