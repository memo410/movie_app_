import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/dish_cards.dart';
import '../widgets/dish_image.dart';
import 'checkout_screen.dart';
import 'dish_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promo = TextEditingController();
  String? _promoError;

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final state = AppScope.read(context);
    final error = state.applyPromo(_promo.text);
    setState(() => _promoError = error);
    if (error == null) {
      HapticFeedback.mediumImpact();
      _promo.clear();
      FocusScope.of(context).unfocus();
      showAppSnack(
        '${state.appliedPromo!.code} applied — ${state.appliedPromo!.description}',
        icon: Icons.local_offer_rounded,
      );
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _removeLine(CartLine line) {
    final state = AppScope.read(context);
    final removed = state.removeLine(line.id);
    if (removed == null) return;
    HapticFeedback.mediumImpact();
    showAppSnack(
      '${removed.line.dish.name} removed',
      icon: Icons.remove_shopping_cart_rounded,
      actionLabel: 'Undo',
      onAction: () => state.restoreLine(removed.line, removed.index),
    );
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.remove_shopping_cart_rounded,
          color: context.colors.error,
        ),
        title: const Text('Empty your cart?'),
        content: const Text(
          'Every item and any applied promo code will be removed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep my cart'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Empty cart'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    AppScope.read(context).clearCart();
    showAppSnack('Cart emptied', icon: Icons.delete_sweep_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (state.isCartEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your cart')),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Your cart is empty',
          message:
              'Browse the menu and add something — the kitchen is open until '
              'midnight tonight.',
          actionLabel: 'Explore the menu',
          onAction: () => goToShellTab(ShellTab.menu),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart · ${state.cartCount}'),
        actions: [
          TextButton.icon(
            onPressed: _confirmClear,
            icon:
                Icon(Icons.delete_outline_rounded, color: context.colors.error),
            label: Text(
              'Empty',
              style: TextStyle(color: context.colors.error),
            ),
          ),
          Gap.w4,
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xxl),
        children: [
          _FreeDeliveryMeter(remaining: state.amountToFreeDelivery),
          Gap.h16,
          for (var i = 0; i < state.lines.length; i++) ...[
            FadeSlideIn.staggered(
              key: ValueKey(state.lines[i].id),
              index: i,
              child: _CartLineTile(
                line: state.lines[i],
                onRemove: () => _removeLine(state.lines[i]),
              ),
            ),
            Gap.h12,
          ],
          Gap.h8,
          _PromoField(
            controller: _promo,
            error: _promoError,
            applied: state.appliedPromo,
            onApply: _applyPromo,
            onRemove: () {
              state.removePromo();
              setState(() => _promoError = null);
              showAppSnack('Promo code removed',
                  icon: Icons.info_outline_rounded);
            },
          ),
          Gap.h24,
          _Suggestions(),
          Gap.h24,
          _Summary(state: state),
        ],
      ),
      bottomNavigationBar:
          _CheckoutBar(total: state.total, count: state.cartCount),
    );
  }
}

class _FreeDeliveryMeter extends StatelessWidget {
  const _FreeDeliveryMeter({required this.remaining});

  final double remaining;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final colors = context.colors;
    final unlocked = remaining <= 0;
    final progress = unlocked
        ? 1.0
        : 1 - (remaining / MenuData.freeDeliveryThreshold).clamp(0.0, 1.0);

    return SoftCard(
      color: unlocked ? brand.successSurface : colors.surfaceContainerLowest,
      bordered: !unlocked,
      child: Row(
        children: [
          Icon(
            unlocked
                ? Icons.check_circle_rounded
                : Icons.delivery_dining_rounded,
            color: unlocked ? brand.success : colors.primary,
            size: IconSize.lg,
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlocked
                      ? 'Free delivery unlocked'
                      : 'Add ${money(remaining)} for free delivery',
                  style: context.text.titleSmall?.copyWith(
                    color: unlocked ? brand.success : colors.onSurface,
                  ),
                ),
                Gap.h8,
                ClipRRect(
                  borderRadius: Radii.pill,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: Motion.slow,
                    curve: Motion.enter,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: colors.surfaceContainerHigh,
                      color: unlocked ? brand.success : colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.onRemove});

  final CartLine line;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = AppScope.of(context);

    return Dismissible(
      key: ValueKey('dismiss-${line.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Gap.lg),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: Radii.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Remove',
              style: context.text.labelLarge?.copyWith(color: colors.onError),
            ),
            Gap.w8,
            Icon(Icons.delete_outline_rounded, color: colors.onError),
          ],
        ),
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(Gap.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 84,
              width: 84,
              child: DishImage(dish: line.dish, radius: Radii.sm),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium,
                  ),
                  if (line.optionsSummary.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      line.optionsSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall,
                    ),
                  ],
                  if (line.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 13,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            line.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Gap.h8,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          money(line.lineTotal),
                          style: context.text.titleMedium?.copyWith(
                            color: colors.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      QuantityStepper(
                        dense: true,
                        quantity: line.quantity,
                        onDecrement: () => line.quantity <= 1
                            ? onRemove()
                            : state.decrementLine(line.id),
                        onIncrement: () => state.incrementLine(line.id),
                      ),
                    ],
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

class _PromoField extends StatelessWidget {
  const _PromoField({
    required this.controller,
    required this.error,
    required this.applied,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final String? error;
  final PromoCode? applied;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = context.brand;

    if (applied != null) {
      return SoftCard(
        color: brand.successSurface,
        bordered: false,
        child: Row(
          children: [
            Icon(Icons.local_offer_rounded, color: brand.success),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applied!.code,
                    style: context.text.titleMedium?.copyWith(
                      color: brand.success,
                    ),
                  ),
                  Text(
                    applied!.description,
                    style: context.text.bodySmall?.copyWith(
                      color: brand.success,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onRemove, child: const Text('Remove')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Have a promo code?', style: context.text.titleMedium),
        Gap.h12,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onApply(),
                decoration: InputDecoration(
                  hintText: 'e.g. SAVORA20',
                  errorText: error,
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                ),
              ),
            ),
            Gap.w12,
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundColor: colors.onSurface,
                ),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
        Gap.h8,
        Wrap(
          spacing: Gap.xs,
          children: [
            for (final promo in MenuData.promoCodes)
              ActionChip(
                label: Text(promo.code),
                avatar: const Icon(Icons.bolt_rounded, size: IconSize.sm),
                onPressed: () {
                  controller.text = promo.code;
                  onApply();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _Suggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inCart = AppScope.of(context).lines.map((l) => l.dish.id).toSet();
    final suggestions = MenuData.byCategory('sides')
        .followedBy(MenuData.byCategory('drinks'))
        .where((d) => !inCart.contains(d.id))
        .take(6)
        .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add something on the side', style: context.text.titleMedium),
        Gap.h12,
        SizedBox(
          height: 296,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => Gap.w12,
            itemBuilder: (context, index) => DishCard(
              dish: suggestions[index],
              heroPrefix: 'cart-suggest',
              onTap: () => openDish(
                context,
                suggestions[index],
                heroPrefix: 'cart-suggest',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return SoftCard(
      padding: const EdgeInsets.all(Gap.md),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: money(state.subtotal)),
          Gap.h12,
          _SummaryRow(
            label: 'Delivery',
            value: state.deliveryFee == 0 ? 'Free' : money(state.deliveryFee),
            valueColor: state.deliveryFee == 0 ? brand.success : null,
          ),
          if (state.discount > 0) ...[
            Gap.h12,
            _SummaryRow(
              label: 'Discount · ${state.appliedPromo!.code}',
              value: '- ${money(state.discount)}',
              valueColor: brand.success,
            ),
          ],
          Gap.h16,
          const HairLine(),
          Gap.h16,
          Row(
            children: [
              Expanded(
                child: Text('Total', style: context.text.titleLarge),
              ),
              AnimatedMoney(
                value: state.total,
                style: context.text.headlineMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: context.text.titleSmall?.copyWith(
            color: valueColor ?? context.colors.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.count});

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
        boxShadow: Shadows.raised(Theme.of(context).brightness),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.md, Gap.sm),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$count items', style: context.text.labelMedium),
                  AnimatedMoney(
                    value: total,
                    style: context.text.titleLarge?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              Gap.w16,
              Expanded(
                child: AppButton(
                  label: 'Checkout',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
