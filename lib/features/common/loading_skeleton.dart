// Skeleton/shimmer placeholders shown while weather loads.
//
// A gentle opacity pulse (no extra dependency) keeps the layout stable
// and supports large text scaling without clipping.
import 'package:flutter/material.dart';

/// Pulsing rounded box used to compose skeleton cards.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color base = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (BuildContext context, double value, _) {
        return Opacity(
          opacity: 1 - (value - 0.4) * 0.5,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }
}

/// Skeleton for the large current-weather card.
class WeatherCardSkeleton extends StatelessWidget {
  const WeatherCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SkeletonBox(width: 140),
            SizedBox(height: 12),
            SkeletonBox(width: 90, height: 56, borderRadius: 12),
            SizedBox(height: 12),
            SkeletonBox(width: 200),
          ],
        ),
      ),
    );
  }
}
