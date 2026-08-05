import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    required this.accents,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<IconData> accents;
}

const List<_Slide> _slides = [
  _Slide(
    icon: Icons.local_fire_department_rounded,
    title: 'Cooked over\nreal wood fire',
    body:
        'Every dish leaves our kitchen within minutes of hitting the flame. '
        'Nothing sits under a heat lamp waiting for a rider.',
    accents: [
      Icons.local_pizza_rounded,
      Icons.outdoor_grill_rounded,
      Icons.bakery_dining_rounded,
    ],
  ),
  _Slide(
    icon: Icons.tune_rounded,
    title: 'Built exactly\nhow you like it',
    body:
        'Pick your size, stack on extras and leave a note for the chef. '
        'We save your favourites so the next order takes seconds.',
    accents: [
      Icons.ramen_dining_rounded,
      Icons.lunch_dining_rounded,
      Icons.icecream_rounded,
    ],
  ),
  _Slide(
    icon: Icons.delivery_dining_rounded,
    title: 'Track it from\npan to door',
    body:
        'Watch your order move through the kitchen and across the city, '
        'with a live estimate that updates as the rider gets closer.',
    accents: [
      Icons.timer_outlined,
      Icons.map_rounded,
      Icons.notifications_active_rounded,
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    AppScope.read(context).completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: Motion.page, curve: Motion.emphasized);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) => _SlideView(
                  slide: _slides[index],
                  controller: _controller,
                  index: index,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.xl,
                Gap.md,
                Gap.xl,
                Gap.xl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: Motion.base,
                          curve: Motion.enter,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: i == _index ? 26 : 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? colors.primary
                                : colors.outline,
                            borderRadius: Radii.pill,
                          ),
                        ),
                    ],
                  ),
                  Gap.h24,
                  AppButton(
                    label: isLast ? 'Get started' : 'Continue',
                    icon: isLast
                        ? Icons.arrow_forward_rounded
                        : Icons.chevron_right_rounded,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.controller,
    required this.index,
  });

  final _Slide slide;
  final PageController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        var delta = 0.0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta = (controller.page ?? index.toDouble()) - index;
        }
        final shift = Motion.reduced(context) ? 0.0 : delta.clamp(-1.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(shift * -60, 0),
                child: Transform.scale(
                  scale: 1 - shift.abs() * 0.12,
                  child: _Illustration(slide: slide),
                ),
              ),
              Gap.h40,
              Transform.translate(
                offset: Offset(shift * -28, 0),
                child: Opacity(
                  opacity: (1 - shift.abs()).clamp(0.0, 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        style: context.text.displayMedium?.copyWith(
                          color: brand.heroEnd,
                        ),
                      ),
                      Gap.h16,
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Text(
                          slide.body,
                          style: context.text.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final colors = context.colors;

    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 210,
            width: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceContainerHigh,
            ),
          ),
          Container(
            height: 148,
            width: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [brand.heroStart, brand.heroEnd],
              ),
              boxShadow: Shadows.brand(brand.heroEnd),
            ),
            child: Icon(slide.icon, size: 66, color: Colors.white),
          ),
          for (var i = 0; i < slide.accents.length; i++)
            Align(
              alignment: [
                const Alignment(-0.92, -0.55),
                const Alignment(0.95, -0.1),
                const Alignment(-0.6, 0.85),
              ][i],
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.outlineVariant),
                  boxShadow: Shadows.card(Theme.of(context).brightness),
                ),
                child: Icon(
                  slide.accents[i],
                  size: IconSize.lg,
                  color: colors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
