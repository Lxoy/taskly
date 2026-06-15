import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';

class HomeSkeletonScreen extends StatefulWidget {
  const HomeSkeletonScreen({super.key});

  @override
  State<HomeSkeletonScreen> createState() => _HomeSkeletonScreenState();
}

class _HomeSkeletonScreenState extends State<HomeSkeletonScreen>
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
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              // ── Header skeleton ──────────────────────────────────────
              SliverToBoxAdapter(child: _HeaderSkeleton(shimmer: _shimmer.value)),

              // ── "OVAJ MJESEC" label ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                  child: _Bone(width: 100, height: 11, shimmer: _shimmer.value),
                ),
              ),

              // ── 2 summary cards ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(child: _SummaryCardSkeleton(shimmer: _shimmer.value)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _SummaryCardSkeleton(shimmer: _shimmer.value)),
                    ],
                  ),
                ),
              ),

              // ── "NADOLAZEĆE OBVEZE" label ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                  child: _Bone(width: 140, height: 11, shimmer: _shimmer.value),
                ),
              ),

              // ── 4 obligation skeletons ───────────────────────────────
              SliverList(
                delegate: SliverChildListDelegate([
                  _ObligationSkeleton(shimmer: _shimmer.value),
                  _ObligationSkeleton(shimmer: _shimmer.value),
                  _ObligationSkeleton(shimmer: _shimmer.value),
                  _ObligationSkeleton(shimmer: _shimmer.value, isLast: true),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header skeleton ───────────────────────────────────────────────────────────

class _HeaderSkeleton extends StatelessWidget {
  final double shimmer;
  const _HeaderSkeleton({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(width: 70, height: 12, shimmer: shimmer, light: true),
                      const SizedBox(height: 6),
                      _Bone(width: 110, height: 16, shimmer: shimmer, light: true),
                    ],
                  ),
                  _Bone(width: 40, height: 40, shimmer: shimmer, light: true,
                      radius: AppRadius.sm),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _Bone(width: 160, height: 38, shimmer: shimmer, light: true),
              const SizedBox(height: 8),
              _Bone(width: 200, height: 12, shimmer: shimmer, light: true),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary card skeleton ─────────────────────────────────────────────────────

class _SummaryCardSkeleton extends StatelessWidget {
  final double shimmer;
  const _SummaryCardSkeleton({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(width: 70, height: 11, shimmer: shimmer),
          const SizedBox(height: AppSpacing.xs),
          _Bone(width: 40, height: 24, shimmer: shimmer),
        ],
      ),
    );
  }
}

// ── Obligation item skeleton ──────────────────────────────────────────────────

class _ObligationSkeleton extends StatelessWidget {
  final double shimmer;
  final bool isLast;

  const _ObligationSkeleton({required this.shimmer, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.md, 0, AppSpacing.md, isLast ? 0 : AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon placeholder
          _Bone(width: 44, height: 44, shimmer: shimmer, radius: AppRadius.sm),
          const SizedBox(width: AppSpacing.md),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 120, height: 13, shimmer: shimmer),
                const SizedBox(height: 6),
                _Bone(width: 80, height: 10, shimmer: shimmer),
              ],
            ),
          ),

          // Amount
          _Bone(width: 56, height: 13, shimmer: shimmer),
        ],
      ),
    );
  }
}

// ── Osnovna "kost" s shimmer efektom ─────────────────────────────────────────

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double shimmer;
  final bool light;
  final double radius;

  const _Bone({
    required this.width,
    required this.height,
    required this.shimmer,
    this.light = false,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = light
        ? Colors.white.withOpacity(0.15)
        : const Color(0xFFE5E7EB);

    final highlightColor = light
        ? Colors.white.withOpacity(0.35)
        : const Color(0xFFF3F4F6);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [baseColor, highlightColor, baseColor],
          transform: _ShimmerTransform(shimmer),
        ),
      ),
    );
  }
}

// ── GradientTransform koji pomiče shimmer ─────────────────────────────────────

class _ShimmerTransform extends GradientTransform {
  final double slide;
  const _ShimmerTransform(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slide, 0, 0);
  }
}