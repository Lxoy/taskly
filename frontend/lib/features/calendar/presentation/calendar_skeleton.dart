import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';

class CalendarSkeletonScreen extends StatefulWidget {
  const CalendarSkeletonScreen({super.key});

  @override
  State<CalendarSkeletonScreen> createState() =>
      _CalendarSkeletonScreenState();
}

class _CalendarSkeletonScreenState extends State<CalendarSkeletonScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        final s = _shimmer.value;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                // ── Top bar skeleton ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Bone(width: 100, height: 24, shimmer: s),
                        _Bone(width: 140, height: 24, shimmer: s),
                      ],
                    ),
                  ),
                ),

                // ── Calendar card skeleton ────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          // Weekday header bones
                          Row(
                            children: List.generate(
                              7,
                              (_) => Expanded(
                                child: Center(
                                  child: _Bone(
                                      width: 24, height: 10, shimmer: s),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // 5 rows of 7 day cells
                          ...List.generate(
                            5,
                            (row) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xs),
                              child: Row(
                                children: List.generate(
                                  7,
                                  (col) => Expanded(
                                    child: Center(
                                      child: _Bone(
                                        width: 32,
                                        height: 32,
                                        shimmer: s,
                                        radius: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Section label skeleton ────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.sm,
                        AppSpacing.md, AppSpacing.sm),
                    child: _Bone(width: 160, height: 11, shimmer: s),
                  ),
                ),

                // ── 4 obligation row skeletons ────────────────────────
                SliverList(
                  delegate: SliverChildListDelegate([
                    _ObligationRowSkeleton(shimmer: s),
                    _ObligationRowSkeleton(shimmer: s),
                    _ObligationRowSkeleton(shimmer: s),
                    _ObligationRowSkeleton(shimmer: s, isLast: true),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Obligation row skeleton ───────────────────────────────────────────────────

class _ObligationRowSkeleton extends StatelessWidget {
  final double shimmer;
  final bool isLast;

  const _ObligationRowSkeleton(
      {required this.shimmer, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, isLast ? 0 : AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
      child: Row(
        children: [
          // Dot
          _Bone(width: 8, height: 8, shimmer: shimmer, radius: 4),
          const SizedBox(width: AppSpacing.md),
          // Title
          Expanded(child: _Bone(width: 120, height: 13, shimmer: shimmer)),
          // Date
          _Bone(width: 36, height: 11, shimmer: shimmer),
          const SizedBox(width: AppSpacing.md),
          // Amount
          _Bone(width: 56, height: 13, shimmer: shimmer),
        ],
      ),
    );
  }
}

// ── Bone widget ───────────────────────────────────────────────────────────────

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double shimmer;
  final double radius;

  const _Bone({
    required this.width,
    required this.height,
    required this.shimmer,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: const [
            Color(0xFFE5E7EB),
            Color(0xFFF3F4F6),
            Color(0xFFE5E7EB),
          ],
          transform: _ShimmerTransform(shimmer),
        ),
      ),
    );
  }
}

class _ShimmerTransform extends GradientTransform {
  final double slide;
  const _ShimmerTransform(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slide, 0, 0);
  }
}