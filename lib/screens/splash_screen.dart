import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import 'onboarding_screen.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brand.heroStart, brand.heroEnd],
        ),
        boxShadow: Shadows.brand(brand.heroEnd),
      ),
      child: Icon(
        Icons.local_fire_department_rounded,
        size: size * 0.52,
        color: Colors.white,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final Animation<double> _markScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
  );

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
  );

  late final Animation<double> _barFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _scheduleExit();
  }

  Future<void> _scheduleExit() async {
    await Future<void>.delayed(const Duration(milliseconds: 2100));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Motion.slow,
        pageBuilder: (_, _, _) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = context.brand;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.surface,
              Color.lerp(colors.surface, brand.heroStart, 0.12)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _markScale,
                child: FadeTransition(
                  opacity: _markScale,
                  child: const BrandMark(size: 108),
                ),
              ),
              Gap.h32,
              FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Text(
                      MenuData.restaurantName,
                      style: context.text.displayMedium?.copyWith(
                        letterSpacing: 4,
                      ),
                    ),
                    Gap.h8,
                    Text(
                      MenuData.restaurantTagline,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _barFade,
                child: SizedBox(
                  width: 148,
                  child: ClipRRect(
                    borderRadius: Radii.pill,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: colors.surfaceContainerHigh,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              Gap.h40,
            ],
          ),
        ),
      ),
    );
  }
}
