import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/dish_image.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final orders = state.orders;

    return Scaffold(
      appBar: AppBar(
        title: Text(orders.isEmpty ? 'Orders' : 'Orders · ${orders.length}'),
      ),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message:
                  'Once you place an order it appears here, so you can track '
                  'it live and reorder later in one tap.',
              actionLabel: 'Browse the menu',
              onAction: () => goToShellTab(ShellTab.menu),
            )
          : ListView.separated(
              padding:
                  const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xxl),
              itemCount: orders.length,
              separatorBuilder: (_, __) => Gap.h12,
              itemBuilder: (context, index) => FadeSlideIn.staggered(
                key: ValueKey(orders[index].id),
                index: index,
                child: _OrderCard(order: orders[index]),
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  String get _placedAt {
    final t = order.placedAt;
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '${t.day}/${t.month}/${t.year} · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = context.brand;
    final state = AppScope.of(context);
    final delivered = order.stage == OrderStage.delivered;
    final statusColor = delivered ? brand.success : colors.secondary;

    return PressScale(
      scale: 0.99,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: order.id),
        ),
      ),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: context.text.titleMedium),
                      Text(_placedAt, style: context.text.labelSmall),
                    ],
                  ),
                ),
                TagPill(
                  icon: order.stage.icon,
                  label: order.stage.title,
                  color: statusColor,
                ),
              ],
            ),
            Gap.h16,
            SizedBox(
              height: 46,
              child: Stack(
                children: [
                  for (var i = 0; i < order.lines.length.clamp(0, 4); i++)
                    Positioned(
                      left: i * 32,
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          borderRadius: Radii.xs,
                          border: Border.all(
                            color: colors.surfaceContainerLowest,
                            width: 2,
                          ),
                        ),
                        child: DishImage(
                          dish: order.lines[i].dish,
                          radius: Radii.xs,
                        ),
                      ),
                    ),
                  if (order.lines.length > 4)
                    Positioned(
                      left: 4 * 32,
                      child: Container(
                        height: 46,
                        width: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: Radii.xs,
                          border: Border.all(
                            color: colors.surfaceContainerLowest,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '+${order.lines.length - 4}',
                          style: context.text.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Gap.h16,
            const HairLine(),
            Gap.h12,
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.itemCount} items · ${money(order.total)}',
                    style: context.text.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    state.reorder(order);
                    showAppSnack(
                      '${order.itemCount} items added to your cart',
                      icon: Icons.shopping_bag_rounded,
                      actionLabel: 'View cart',
                      onAction: () => goToShellTab(ShellTab.cart),
                    );
                  },
                  icon: const Icon(Icons.replay_rounded, size: IconSize.sm),
                  label: const Text('Reorder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
