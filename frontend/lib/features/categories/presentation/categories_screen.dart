import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/core/utils/icon_registry.dart';
import 'package:frontend/data/models/category_models.dart';
import 'package:frontend/features/categories/bloc/category_bloc.dart';

// ── Color palette ─────────────────────────────────────────────────────────────

const _colorOptions = [
  '#F59E0B', '#EC4899', '#3B82F6', '#10B981', '#8B5CF6',
  '#EF4444', '#06B6D4', '#F97316', '#6366F1', '#84CC16',
  '#14B8A6', '#E11D48', '#7C3AED', '#0EA5E9', '#D97706',
  '#059669', '#DC2626', '#9333EA', '#2563EB', '#16A34A',
];

Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryBloc>()..add(const CategoriesFetchRequested()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
              );
            }
          },
          builder: (context, state) {
            final categories = switch (state) {
              CategoryLoaded(:final categories)   => categories,
              CategoryMutating(:final categories) => categories,
              CategoryError(:final categories)    => categories,
              _                                   => null,
            };
            final isMutating = state is CategoryMutating;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Categories',
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.textPrimary)),
                      const Spacer(),
                      if (isMutating)
                        const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm,
                      AppSpacing.md, AppSpacing.lg),
                  child: Text(
                    'Organise your activities with custom categories.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),

                // ── List / skeleton / empty ────────────────────────────
                Expanded(
                  child: switch (state) {
                    CategoryInitial() || CategoryLoading() =>
                      const _CategoriesSkeleton(),
                    _ when categories != null && categories.isEmpty =>
                      const _EmptyState(),
                    _ when categories != null => _CategoryList(
                        categories: categories,
                        isMutating: isMutating,
                      ),
                    _ => const SizedBox.shrink(),
                  },
                ),

                // ── Add button ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GestureDetector(
                    onTap: isMutating
                        ? null
                        : () => _showFormSheet(context),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isMutating ? 0.6 : 1.0,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Add Category',
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFormSheet(BuildContext context, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: _CategoryFormSheet(initial: category),
      ),
    );
  }
}

// ── Reorderable list ──────────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  final List<Category> categories;
  final bool isMutating;

  const _CategoryList({required this.categories, required this.isMutating});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: categories.length,
      onReorder: (_, __) {},
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _CategoryRow(
          key: ValueKey(cat.id),
          category: cat,
          isMutating: isMutating,
          onEdit: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => BlocProvider.value(
              value: context.read<CategoryBloc>(),
              child: _CategoryFormSheet(initial: cat),
            ),
          ),
          onDelete: () => _confirmDelete(context, cat),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Category cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete category?',
            style: AppTextStyles.subtitle
                .copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Delete "${cat.name}"? Existing entries won\'t be affected.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<CategoryBloc>()
                  .add(CategoryDeleteRequested(cat.id));
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Category row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final Category category;
  final bool isMutating;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryRow({
    super.key,
    required this.category,
    required this.isMutating,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color    = _hexToColor(category.color);
    final iconData = IconRegistry.get(category.icon);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(iconData, color: color, size: 20),
        ),
        title: Text(category.name,
            style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isMutating ? null : onEdit,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: isMutating ? null : onDelete,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Icon(Icons.delete_outline_rounded,
                    size: 16, color: AppColors.danger),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.drag_handle_rounded,
                size: 20,
                color: AppColors.textSecondary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

// ── Add / Edit sheet ──────────────────────────────────────────────────────────

class _CategoryFormSheet extends StatefulWidget {
  final Category? initial;
  const _CategoryFormSheet({this.initial});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _nameCtrl;
  late String _selectedColor;
  late String _selectedIconKey;

  @override
  void initState() {
    super.initState();
    _nameCtrl        = TextEditingController(text: widget.initial?.name ?? '');
    _selectedColor   = widget.initial?.color ?? _colorOptions.first;
    _selectedIconKey = widget.initial?.icon  ?? IconRegistry.keys.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final bloc = context.read<CategoryBloc>();
    if (widget.initial != null) {
      bloc.add(CategoryUpdateRequested(
        id:    widget.initial!.id,
        name:  name,
        color: _selectedColor,
        icon:  _selectedIconKey,
      ));
    } else {
      bloc.add(CategoryCreateRequested(
        name:  name,
        color: _selectedColor,
        icon:  _selectedIconKey,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit       = widget.initial != null;
    final bottom       = MediaQuery.of(context).viewInsets.bottom;
    final previewColor = _hexToColor(_selectedColor);
    final previewIcon  = IconRegistry.get(_selectedIconKey);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm,
          AppSpacing.md, AppSpacing.md + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEdit ? 'Edit Category' : 'New Category',
                    style: AppTextStyles.subtitle
                        .copyWith(color: AppColors.textPrimary)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Preview
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: previewColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(previewIcon, color: previewColor, size: 30),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _nameCtrl.text.isEmpty ? 'Category name' : _nameCtrl.text,
                    style: AppTextStyles.body.copyWith(
                      color: _nameCtrl.text.isEmpty
                          ? AppColors.textSecondary.withOpacity(0.4)
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Name
            _Label('Name'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Groceries, Rent...',
                  hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.label_outline_rounded,
                      size: 18, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon picker
            _Label('Icon'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: IconRegistry.keys.map((key) {
                final sel       = _selectedIconKey == key;
                final iconColor = sel ? previewColor : AppColors.textSecondary;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconKey = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: sel
                          ? previewColor.withOpacity(0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: sel ? previewColor : const Color(0xFFE5E7EB),
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Icon(IconRegistry.get(key), size: 22, color: iconColor),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color picker
            _Label('Color'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _colorOptions.map((hex) {
                final sel   = _selectedColor == hex;
                final color = _hexToColor(hex);
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: sel ? AppColors.textPrimary : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: sel
                          ? [BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Save
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(isEdit ? 'Save Changes' : 'Add Category',
                      style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _CategoriesSkeleton extends StatefulWidget {
  const _CategoriesSkeleton();

  @override
  State<_CategoriesSkeleton> createState() => _CategoriesSkeletonState();
}

class _CategoriesSkeletonState extends State<_CategoriesSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 1.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 5,
        itemBuilder: (_, __) => _SkeletonRow(s: _shimmer.value),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  final double s;
  const _SkeletonRow({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          _Bone(w: 42, h: 42, s: s, r: AppRadius.sm),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _Bone(w: 100, h: 14, s: s)),
          _Bone(w: 34, h: 34, s: s, r: AppRadius.sm),
          const SizedBox(width: AppSpacing.sm),
          _Bone(w: 34, h: 34, s: s, r: AppRadius.sm),
        ],
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined,
                size: 56,
                color: AppColors.textSecondary.withOpacity(0.25)),
            const SizedBox(height: AppSpacing.md),
            Text('No categories yet',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Tap "Add Category" to get started.',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.6))),
          ],
        ),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      );
}

class _Bone extends StatelessWidget {
  final double w, h, s, r;
  const _Bone({required this.w, required this.h, required this.s, this.r = 6});

  @override
  Widget build(BuildContext context) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: LinearGradient(
            stops: const [0.0, 0.5, 1.0],
            colors: const [
              Color(0xFFE5E7EB),
              Color(0xFFF3F4F6),
              Color(0xFFE5E7EB),
            ],
            transform: _ShimmerTransform(s),
          ),
        ),
      );
}

class _ShimmerTransform extends GradientTransform {
  final double slide;
  const _ShimmerTransform(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}