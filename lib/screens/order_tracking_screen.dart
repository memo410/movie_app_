import 'dart:async';

import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/dish_image.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? _timer;
  int _minutesLeft = 42;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final state = AppScope.read(context);
      state.advanceOrder(widget.orderId);
      setState(() {
        _minutesLeft = (_minutesLeft - 12).clamp(0, 60);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Order? _findOrder(AppState state) {
    for (final order in state.orders) {
      if (order.id == widget.orderId) return order;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final order = _findOrder(state);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'We cannot find that order',
          message:
              'It may have been cleared when you signed out. Your order '
              'history lives in the Orders tab.',
          actionLabel: 'Go to orders',
          onAction: () => goToShellTab(ShellTab.orders),
        ),
      );
    }

    final delivered = order.stage == OrderStage.delivered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.id}'),
        actions: [
          IconButton(
            tooltip: 'Help with this order',
            onPressed: () => showAppSnack(
              'Support is not available in this demo build.',
              icon: Icons.support_agent_rounded,
            ),
            icon: const Icon(Icons.help_outline_rounded),
          ),
          Gap.w4,
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xxl),
        children: [
          _EtaCard(
            minutesLeft: _minutesLeft,
            stage: order.stage,
            delivered: delivered,
          ),
          Gap.h24,
          Text('Progress', style: context.text.headlineSmall),
          Gap.h16,
          _Timeline(stage: order.stage),
          Gap.h24,
          if (!delivered) _RiderCard(),
          if (!delivered) Gap.h24,
          Text('Order summary', style: context.text.headlineSmall),
          Gap.h12,
          SoftCard(
            child: Column(
              children: [
                for (var i = 0; i < order.lines.length; i++) ...[
                  if (i > 0) ...[Gap.h12, const HairLine(), Gap.h12],
                  Row(
                    children: [
                      SizedBox(
                        height: 44,
                        width: 44,
                        child: DishImage(
                          dish: order.lines[i].dish,
                          radius: Radii.xs,
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.lines[i].dish.name,
                              style: context.text.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${order.lines[i].quantity} × '
                              '${money(order.lines[i].unitPrice)}',
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        money(order.lines[i].lineTotal),
                        style: context.text.titleSmall,
                      ),
                    ],
                  ),
                ],
                Gap.h16,
                const HairLine(),
                Gap.h16,
                Row(
                  children: [
                    Expanded(
                      child: Text('Total paid', style: context.text.titleMedium),
                    ),
                    Text(
                      money(order.total),
                      style: context.text.titleLarge?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap.h24,
          SoftCard(
            child: Row(
              children: [
                Icon(order.address.icon, color: context.colors.primary),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.address.label, style: context.text.titleSmall),
                      Text(order.address.line, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap.h24,
          if (delivered)
            AppButton(
              label: 'Order this again',
              icon: Icons.replay_rounded,
              onPressed: () {
                state.reorder(order);
                showAppSnack(
                  '${order.itemCount} items added back to your cart',
                  icon: Icons.shopping_bag_rounded,
                  actionLabel: 'View cart',
                  onAction: () => goToShellTab(ShellTab.cart),
                );
              },
            )
          else
            OutlinedButton.icon(
              onPressed: () => showAppSnack(
                'Cancellation is not available once cooking has started.',
                icon: Icons.info_outline_rounded,
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel order'),
            ),
        ],
      ),
    );
  }
}

class _EtaCard extends StatelessWidget {
  const _EtaCard({
    required this.minutesLeft,
    required this.stage,
    required this.delivered,
  });

  final int minutesLeft;
  final OrderStage stage;
  final bool delivered;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        borderRadius: Radii.lg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: delivered
              ? [brand.success, brand.success.withValues(alpha: 0.72)]
              : [brand.heroStart, brand.heroEnd],
        ),
        boxShadow: Shadows.raised(Theme.of(context).brightness),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivered ? 'Delivered' : 'Arriving in',
                  style: context.text.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Gap.h4,
                AnimatedSwitcher(
                  duration: Motion.base,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.vertical,
                      child: child,
                    ),
                  ),
                  child: Text(
                    delivered ? 'Enjoy your meal' : '$minutesLeft min',
                    key: ValueKey('$delivered-$minutesLeft'),
                    style: context.text.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Gap.h4,
                Text(
                  stage.subtitle,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
          _PulsingIcon(icon: stage.icon, active: !delivered),
        ],
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(_PulsingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = Motion.reduced(context) || !widget.active;

    return SizedBox(
      height: 76,
      width: 76,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = still ? 0.0 : _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (!still)
                Container(
                  height: 46 + t * 30,
                  width: 46 + t * 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.28 * (1 - t)),
                  ),
                ),
              child!,
            ],
          );
        },
        child: Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.22),
          ),
          child: Icon(widget.icon, color: Colors.white, size: IconSize.lg),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.stage});

  final OrderStage stage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = context.brand;

    return Column(
      children: [
        for (var i = 0; i < OrderStage.values.length; i++)
          Builder(
            builder: (context) {
              final item = OrderStage.values[i];
              final done = i < stage.index;
              final current = i == stage.index;
              final tint = done
                  ? brand.success
                  : current
                      ? colors.primary
                      : colors.onSurfaceVariant;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: Motion.base,
                          curve: Motion.enter,
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done || current
                                ? tint
                                : colors.surfaceContainerHigh,
                            border: Border.all(color: tint, width: 2),
                          ),
                          child: Icon(
                            done ? Icons.check_rounded : item.icon,
                            size: IconSize.sm,
                            color: done || current
                                ? Colors.white
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        if (i < OrderStage.values.length - 1)
                          Expanded(
                            child: AnimatedContainer(
                              duration: Motion.slow,
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: done ? brand.success : colors.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                    Gap.w16,
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: i == OrderStage.values.length - 1 ? 0 : Gap.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: context.text.titleMedium?.copyWith(
                                      color: done || current
                                          ? colors.onSurface
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                if (current)
                                  TagPill(
                                    icon: Icons.circle,
                                    label: 'Now',
                                    compact: true,
                                    color: colors.primary,
                                  ),
                              ],
                            ),
                            Text(item.subtitle, style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _RiderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SoftCard(
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_motorsports_rounded,
              color: colors.onPrimaryContainer,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kareem A.', style: context.text.titleMedium),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: context.brand.rating,
                    ),
                    const SizedBox(width: 3),
                    Text('4.9 · 1,204 deliveries',
                        style: context.text.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Message the rider',
            onPressed: () => showAppSnack(
              'Messaging is not available in this demo build.',
              icon: Icons.chat_bubble_outline_rounded,
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
          IconButton(
            tooltip: 'Call the rider',
            onPressed: () => showAppSnack(
              'Calling is not available in this demo build.',
              icon: Icons.phone_outlined,
            ),
            icon: const Icon(Icons.phone_outlined),
          ),
        ],
      ),
    );
  }
}
