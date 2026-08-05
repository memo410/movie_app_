import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'common.dart';
import 'dish_image.dart';

class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.rating,
    this.reviewCount,
    this.compact = false,
  });

  final double rating;
  final int? reviewCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = reviewCount == null
        ? 'Rated $rating out of 5'
        : 'Rated $rating out of 5 from $reviewCount reviews';

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? IconSize.sm : IconSize.md,
            color: context.brand.rating,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: (compact ? context.text.labelMedium : context.text.titleSmall)
                ?.copyWith(color: context.colors.onSurface),
          ),
          if (reviewCount != null) ...[
            const SizedBox(width: 3),
            Text(
              '($reviewCount)',
              style: context.text.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

class FavouriteButton extends StatefulWidget {
  const FavouriteButton({
    super.key,
    required this.dish,
    this.onSurface = false,
  });

  final Dish dish;
  final bool onSurface;

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.slow,
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final state = AppScope.read(context);
    final added = state.toggleFavourite(widget.dish.id);
    HapticFeedback.lightImpact();
    if (added && !Motion.reduced(context)) {
      _controller.forward(from: 0);
    }
    showAppSnack(added
          ? '${widget.dish.name} saved to favourites'
          : '${widget.dish.name} removed from favourites',
      icon: added ? Icons.favorite_rounded : Icons.heart_broken_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFavourite = AppScope.of(context).isFavourite(widget.dish.id);
    final colors = context.colors;

    return Semantics(
      button: true,
      toggled: isFavourite,
      onTap: _toggle,
      label: isFavourite
          ? 'Remove ${widget.dish.name} from favourites'
          : 'Save ${widget.dish.name} to favourites',
      child: ExcludeSemantics(
        child: Material(
          color: widget.onSurface
              ? colors.surfaceContainerLowest.withValues(alpha: 0.92)
              : colors.surfaceContainerHigh,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _toggle,
            child: SizedBox(
              height: kMinTouchTarget - 6,
              width: kMinTouchTarget - 6,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulse =
                      1 + Curves.easeOutBack.transform(_controller.value) * 0.25;
                  return Transform.scale(
                    scale: _controller.isAnimating ? pulse : 1,
                    child: child,
                  );
                },
                child: AnimatedSwitcher(
                  duration: Motion.fast,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isFavourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(isFavourite),
                    size: IconSize.md,
                    color: isFavourite ? colors.error : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.xs, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.error,
        borderRadius: Radii.pill,
      ),
      child: Text(
        '-$percent%',
        style: context.text.labelSmall?.copyWith(
          color: context.colors.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PriceText extends StatelessWidget {
  const PriceText({super.key, required this.dish, this.style});

  final Dish dish;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? context.text.titleMedium;

    if (!dish.isDiscounted) {
      return Text(
        money(dish.basePrice),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base?.copyWith(
          color: context.colors.onSurface,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            money(dish.effectivePrice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: base?.copyWith(
              color: context.colors.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Gap.w4,
        Flexible(
          child: Text(
            money(dish.basePrice),
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class DishCard extends StatelessWidget {
  const DishCard({
    super.key,
    required this.dish,
    required this.onTap,
    this.width = 196,
    this.heroPrefix = 'card',
  });

  final Dish dish;
  final VoidCallback onTap;
  final double width;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      semanticLabel:
          '${dish.name}. ${dish.tagline}. ${money(dish.effectivePrice)}. '
          'Rated ${dish.rating} out of 5.',
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          child: SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DishImage(
                        dish: dish,
                        radius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        heroTag: '$heroPrefix-${dish.id}',
                      ),
                      Positioned(
                        top: Gap.xs,
                        right: Gap.xs,
                        child: FavouriteButton(dish: dish, onSurface: true),
                      ),
                      if (dish.isDiscounted)
                        Positioned(
                          top: Gap.sm,
                          left: Gap.sm,
                          child: DiscountBadge(percent: dish.discountPercent),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Gap.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium,
                      ),
                      Gap.h4,
                      Text(
                        dish.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                      Gap.h12,
                      Row(
                        children: [
                          Expanded(child: PriceText(dish: dish)),
                          Gap.w8,
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${dish.prepMinutes}m',
                            style: context.text.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DishRow extends StatelessWidget {
  const DishRow({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.heroPrefix = 'row',
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inCart = AppScope.of(context).quantityOf(dish.id);

    return PressScale(
      onTap: onTap,
      scale: 0.985,
      semanticLabel:
          '${dish.name}. ${dish.tagline}. ${money(dish.effectivePrice)}. '
          'Rated ${dish.rating} out of 5.',
      child: ExcludeSemantics(
        child: SoftCard(
          padding: const EdgeInsets.all(Gap.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 104,
                width: 104,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DishImage(
                        dish: dish,
                        radius: Radii.sm,
                        heroTag: '$heroPrefix-${dish.id}',
                      ),
                    ),
                    if (dish.isDiscounted)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: DiscountBadge(percent: dish.discountPercent),
                      ),
                  ],
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleMedium,
                          ),
                        ),
                        RatingRow(rating: dish.rating, compact: true),
                      ],
                    ),
                    Gap.h4,
                    Text(
                      dish.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall,
                    ),
                    Gap.h8,
                    if (dish.tags.isNotEmpty)
                      Wrap(
                        spacing: Gap.xxs,
                        runSpacing: Gap.xxs,
                        children: [
                          for (final tag in dish.tags.take(2))
                            TagPill(
                              icon: tag.icon,
                              label: tag.label,
                              compact: true,
                              color: switch (tag) {
                                DishTag.spicy => context.brand.spicy,
                                DishTag.vegetarian => context.brand.veg,
                                DishTag.bestseller => colors.primary,
                                _ => colors.onSurfaceVariant,
                              },
                            ),
                        ],
                      ),
                    Gap.h8,
                    Row(
                      children: [
                        Expanded(child: PriceText(dish: dish)),
                        Gap.w8,
                        _AddButton(count: inCart, onAdd: onAdd),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.count, required this.onAdd});

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      onTap: onAdd,
      label: count == 0 ? 'Add to cart' : '$count in cart, add another',
      child: ExcludeSemantics(
        child: Material(
          color: count == 0 ? colors.primaryContainer : colors.primary,
          borderRadius: Radii.sm,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onAdd();
            },
            child: SizedBox(
              height: 40,
              width: count == 0 ? 52 : 60,
              child: AnimatedSwitcher(
                duration: Motion.fast,
                child: count == 0
                    ? Icon(
                        Icons.add_rounded,
                        key: const ValueKey('add'),
                        color: colors.onPrimaryContainer,
                      )
                    : Row(
                        key: const ValueKey('count'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: IconSize.sm,
                            color: colors.onPrimary,
                          ),
                          Text(
                            '$count',
                            style: context.text.labelLarge?.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final MenuCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      label: category.name,
      child: ExcludeSemantics(
        child: PressScale(
          onTap: onTap,
          scale: 0.94,
          child: AnimatedContainer(
            duration: Motion.base,
            curve: Motion.enter,
            constraints: const BoxConstraints(minHeight: kMinTouchTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: Gap.sm,
            ),
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surfaceContainerLowest,
              borderRadius: Radii.pill,
              border: Border.all(
                color: selected ? colors.primary : colors.outline,
              ),
              boxShadow: selected ? Shadows.brand(colors.primary) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: IconSize.sm,
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                ),
                Gap.w8,
                Text(
                  category.name,
                  style: context.text.labelLarge?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.min = 1,
    this.max = 20,
    this.dense = false,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final int min;
  final int max;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final side = dense ? 36.0 : 44.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: Radii.pill,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: quantity <= min
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            label: quantity <= min ? 'Remove item' : 'Decrease quantity',
            side: side,
            danger: quantity <= min,
            onTap: onDecrement,
          ),
          AnimatedSwitcher(
            duration: Motion.fast,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: SizedBox(
              key: ValueKey(quantity),
              width: dense ? 28 : 34,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: context.text.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: 'Increase quantity',
            side: side,
            onTap: quantity >= max ? null : onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.side,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final double side;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      onTap: onTap,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  }
                : null,
            child: SizedBox(
              height: side,
              width: side,
              child: Icon(
                icon,
                size: IconSize.md,
                color: !enabled
                    ? colors.onSurface.withValues(alpha: 0.38)
                    : danger
                        ? colors.error
                        : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.actionLabel = 'Order now',
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return PressScale(
      onTap: onTap,
      scale: 0.98,
      semanticLabel: '$title. $subtitle. $actionLabel',
      child: ExcludeSemantics(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            borderRadius: Radii.lg,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [brand.heroStart, brand.heroEnd],
            ),
            boxShadow: Shadows.raised(Theme.of(context).brightness),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -28,
                bottom: -34,
                child: Icon(
                  icon,
                  size: 132,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Gap.h4,
                  Flexible(
                    child: SizedBox(
                      width: 190,
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ),
                  Gap.h12,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Gap.md,
                      vertical: Gap.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: Radii.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel,
                          style: context.text.labelLarge?.copyWith(
                            color: brand.heroEnd,
                          ),
                        ),
                        Gap.w4,
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: IconSize.sm,
                          color: brand.heroEnd,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DishCardSkeleton extends StatelessWidget {
  const DishCardSkeleton({super.key, this.width = 196});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AspectRatio(
              aspectRatio: 4 / 3,
              child: Skeleton(
                height: double.infinity,
                radius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Gap.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(height: 14, width: width * 0.7),
                  Gap.h8,
                  Skeleton(height: 12, width: width * 0.9),
                  Gap.h12,
                  const Skeleton(height: 16, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

MenuCategory categoryOf(Dish dish) => MenuData.categoryById(dish.categoryId);
