import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';

/// Prikaži unutar bottom sheeta dok se kategorije učitavaju s API-ja.
/// Zamijeni sadržaj bottom sheeta s ovim widgetom dok je state == loading.
class AddEntrySkeletonSheet extends StatefulWidget {
  const AddEntrySkeletonSheet({super.key});

  @override
  State<AddEntrySkeletonSheet> createState() =>
      _AddEntrySkeletonSheetState();
}

class _AddEntrySkeletonSheetState extends State<AddEntrySkeletonSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 1.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
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
      builder: (context, _) {
        final s = _shimmer.value;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Bone(w: 140, h: 22, s: s),
                  _Bone(w: 32, h: 32, s: s, r: AppRadius.sm),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  height: 1),
              const SizedBox(height: AppSpacing.lg),

              // Naziv
              _Bone(w: 50, h: 11, s: s),
              const SizedBox(height: AppSpacing.sm),
              _Bone(w: double.infinity, h: 48, s: s, r: AppRadius.md),
              const SizedBox(height: AppSpacing.lg),

              // Iznos
              _Bone(w: 80, h: 11, s: s),
              const SizedBox(height: AppSpacing.sm),
              _Bone(w: double.infinity, h: 48, s: s, r: AppRadius.md),
              const SizedBox(height: AppSpacing.lg),

              // Kategorija chips
              _Bone(w: 80, h: 11, s: s),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Bone(w: 80, h: 34, s: s, r: AppRadius.xl),
                  const SizedBox(width: AppSpacing.sm),
                  _Bone(w: 80, h: 34, s: s, r: AppRadius.xl),
                  const SizedBox(width: AppSpacing.sm),
                  _Bone(w: 80, h: 34, s: s, r: AppRadius.xl),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Prioritet segmented
              _Bone(w: 70, h: 11, s: s),
              const SizedBox(height: AppSpacing.sm),
              _Bone(w: double.infinity, h: 44, s: s, r: AppRadius.md),
              const SizedBox(height: AppSpacing.lg),

              // Ponavljanje chips
              _Bone(w: 90, h: 11, s: s),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Bone(w: 90, h: 34, s: s, r: AppRadius.xl),
                  const SizedBox(width: AppSpacing.sm),
                  _Bone(w: 70, h: 34, s: s, r: AppRadius.xl),
                  const SizedBox(width: AppSpacing.sm),
                  _Bone(w: 80, h: 34, s: s, r: AppRadius.xl),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),


              // Interval (uvjetno)
              _Bone(w: 120, h: 11, s: s),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Bone(w: 48, h: 48, s: s, r: AppRadius.md),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _Bone(w: double.infinity, h: 48, s: s, r: AppRadius.md)),
                  const SizedBox(width: AppSpacing.sm),
                  _Bone(w: 48, h: 48, s: s, r: AppRadius.md),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Datum
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bone(w: 60, h: 11, s: s),
                        const SizedBox(height: AppSpacing.sm),
                        _Bone(w: double.infinity, h: 44, s: s, r: AppRadius.md),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bone(w: 100, h: 11, s: s),
                        const SizedBox(height: AppSpacing.sm),
                        _Bone(w: double.infinity, h: 44, s: s, r: AppRadius.md),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Submit button
              _Bone(w: double.infinity, h: 52, s: s, r: AppRadius.md),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}

// ── Bone ──────────────────────────────────────────────────────────────────────

class _Bone extends StatelessWidget {
  final double w;
  final double h;
  final double s;
  final double r;

  const _Bone({
    required this.w,
    required this.h,
    required this.s,
    this.r = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
}

class _ShimmerTransform extends GradientTransform {
  final double slide;
  const _ShimmerTransform(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}