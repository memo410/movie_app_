import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../models/models.dart';
import 'common.dart';

class DishImage extends StatelessWidget {
  const DishImage({
    super.key,
    required this.dish,
    this.radius = Radii.md,
    this.iconScale = 1,
    this.heroTag,
  });

  final Dish dish;
  final BorderRadius radius;
  final double iconScale;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: radius,
      child: dish.imageUrl == null
          ? _Fallback(dish: dish, iconScale: iconScale)
          : Image.network(
              dish.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _Loading(radius: radius);
              },
              errorBuilder: (context, __, ___) =>
                  _Fallback(dish: dish, iconScale: iconScale),
            ),
    );

    if (heroTag == null) return content;
    return Hero(
      tag: heroTag!,
      flightShuttleBuilder: (_, animation, __, ___, ____) => FadeTransition(
        opacity: animation.drive(Tween(begin: 0.85, end: 1)),
        child: content,
      ),
      child: content,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.radius});

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      height: double.infinity,
      width: double.infinity,
      radius: radius,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.dish, required this.iconScale});

  final Dish dish;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final seed = dish.id.codeUnits.fold<int>(0, (a, b) => a + b);
    final rotation = (seed % 8) * 0.12;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(brand.heroStart, brand.heroEnd, rotation)!,
            brand.heroEnd,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -side * 0.22,
                top: -side * 0.28,
                child: Container(
                  height: side * 0.85,
                  width: side * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  dish.icon,
                  size: (side * 0.4 * iconScale).clamp(20.0, 96.0),
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

