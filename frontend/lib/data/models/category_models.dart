// ── Response model ← GET /api/category ───────────────────────────────────────

class Category {
  final int id;
  final String name;
  final String color;
  final String icon;
 
  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
 
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id:    json['id'] as int,
      name:  json['name'] as String,
      color: json['color'] as String,
      icon:  (json['icon'] as String?) ?? 'label_rounded',
    );
  }
}
 
class CreateCategoryRequest {
  final String name;
  final String color;
  final String icon;
 
  const CreateCategoryRequest({
    required this.name,
    required this.color,
    required this.icon,
  });
 
  Map<String, dynamic> toJson() => {'name': name, 'color': color, 'icon': icon};
}
 
class UpdateCategoryRequest {
  final String name;
  final String color;
  final String icon;
 
  const UpdateCategoryRequest({
    required this.name,
    required this.color,
    required this.icon,
  });
 
  Map<String, dynamic> toJson() => {'name': name, 'color': color, 'icon': icon};
}
 

// ── Result wrappers ───────────────────────────────────────────────────────────

sealed class CategoryResult<T> {
  const CategoryResult();
}

class CategorySuccess<T> extends CategoryResult<T> {
  final T data;
  const CategorySuccess(this.data);
}

class CategoryFailure<T> extends CategoryResult<T> {
  final String message;
  const CategoryFailure(this.message);
}