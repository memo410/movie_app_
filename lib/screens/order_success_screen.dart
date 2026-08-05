import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'order_tracking_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final colors = context.colors;
    final order = widget.order;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goToShellTab(ShellTab.home);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Gap.xl),
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: 180,
                  width: 180,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => CustomPaint(
                      painter: _SuccessPainter(
                        progress: Motion.reduced(context)
                            ? 1
                            : _controller.value,
                        ring: brand.success,
                        check: brand.success,
                        halo: brand.success.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                ),
                Gap.h32,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    'Order placed',
                    style: context.text.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Gap.h8,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 580),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Text(
                      'The kitchen has your order and will start cooking in a '
                      'moment. We will keep you posted at every step.',
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Gap.h32,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 660),
                  child: SoftCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _Fact(
                            label: 'Order',
                            value: order.id,
                            icon: Icons.receipt_long_rounded,
                          ),
                        ),
                        SizedBox(
                          height: 42,
                          child: VerticalDivider(color: colors.outlineVariant),
                        ),
                        Expanded(
                          child: _Fact(
                            label: 'Items',
                            value: '${order.itemCount}',
                            icon: Icons.lunch_dining_rounded,
                          ),
                        ),
                        SizedBox(
                          height: 42,
                          child: VerticalDivider(color: colors.outlineVariant),
                        ),
                        Expanded(
                          child: _Fact(
                            label: 'Total',
                            value: money(order.total),
                            icon: Icons.payments_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 740),
                  child: AppButton(
                    label: 'Track my order',
                    icon: Icons.delivery_dining_rounded,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(orderId: order.id),
                      ),
                    ),
                  ),
                ),
                Gap.h12,
                TextButton(
                  onPressed: () => goToShellTab(ShellTab.home),
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: IconSize.md, color: context.colors.primary),
        Gap.h4,
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.titleSmall,
        ),
        Text(label, style: context.text.labelSmall),
      ],
    );
  }
}

class _SuccessPainter extends CustomPainter {
  _SuccessPainter({
    required this.progress,
    required this.ring,
    required this.check,
    required this.halo,
  });

  final double progress;
  final Color ring;
  final Color check;
  final Color halo;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 18;

    final haloProgress = Curves.easeOut.transform(
      (progress / 0.7).clamp(0.0, 1.0),
    );
    canvas.drawCircle(
      center,
      radius * (0.7 + haloProgress * 0.55),
      Paint()..color = halo.withValues(alpha: halo.a * (1 - haloProgress)),
    );

    final ringProgress = Curves.easeOutCubic.transform(
      (progress / 0.55).clamp(0.0, 1.0),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * ringProgress,
      false,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    final checkProgress = Curves.easeOutCubic.transform(
      ((progress - 0.45) / 0.4).clamp(0.0, 1.0),
    );
    if (checkProgress <= 0) return;

    final start = center + Offset(-radius * 0.38, radius * 0.02);
    final elbow = center + Offset(-radius * 0.1, radius * 0.32);
    final end = center + Offset(radius * 0.42, -radius * 0.3);

    final path = Path()..moveTo(start.dx, start.dy);
    if (checkProgress <= 0.45) {
      final t = checkProgress / 0.45;
      path.lineTo(
        start.dx + (elbow.dx - start.dx) * t,
        start.dy + (elbow.dy - start.dy) * t,
      );
    } else {
      final t = (checkProgress - 0.45) / 0.55;
      path
        ..lineTo(elbow.dx, elbow.dy)
        ..lineTo(
          elbow.dx + (end.dx - elbow.dx) * t,
          elbow.dy + (end.dy - elbow.dy) * t,
        );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = check
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SuccessPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
