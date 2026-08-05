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

void openDish(BuildContext context, Dish dish, {String heroPrefix = 'card'}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DishDetailScreen(dish: dish, heroPrefix: heroPrefix),
    ),
  );
}

void quickAdd(BuildContext context, Dish dish) {
  final state = AppScope.read(context);
  state.addToCart(
    dish,
    size: dish.sizes.isEmpty ? null : dish.sizes[dish.sizes.length ~/ 2],
  );
  HapticFeedback.lightImpact();
  showAppSnack('${dish.name} added to your cart',
    icon: Icons.shopping_bag_rounded,
    actionLabel: 'View cart',
    onAction: () => goToShellTab(ShellTab.cart),
  );
}

class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({
    super.key,
    required this.dish,
    this.heroPrefix = 'card',
  });

  final Dish dish;
  final String heroPrefix;

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  late PortionSize? _size = widget.dish.sizes.isEmpty
      ? null
      : widget.dish.sizes[widget.dish.sizes.length ~/ 2];
  final Set<String> _addOns = {};
  final TextEditingController _note = TextEditingController();
  int _quantity = 1;
  bool _adding = false;

  Dish get dish => widget.dish;

  double get _unitPrice => dish.priceFor(_size, _addOns);
  double get _total => _unitPrice * _quantity;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    setState(() => _adding = true);
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    AppScope.read(context).addToCart(
      dish,
      quantity: _quantity,
      size: _size,
      addOnIds: _addOns,
      note: _note.text.trim(),
    );
    HapticFeedback.mediumImpact();
    setState(() => _adding = false);

    showAppSnack(
      '$_quantity × ${dish.name} added',
      icon: Icons.shopping_bag_rounded,
      actionLabel: 'View cart',
      onAction: () => goToShellTab(ShellTab.cart),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final category = MenuData.categoryById(dish.categoryId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: colors.surface,
            leading: const _RoundBackButton(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: Gap.xs),
                child: FavouriteButton(dish: dish, onSurface: true),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DishImage(
                    dish: dish,
                    radius: BorderRadius.zero,
                    iconScale: 1.4,
                    heroTag: '${widget.heroPrefix}-${dish.id}',
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.45, 1],
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          colors.surface,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, 140),
            sliver: SliverList.list(
              children: [
                FadeSlideIn(
                  child: Row(
                    children: [
                      TagPill(
                        icon: category.icon,
                        label: category.name,
                        color: colors.primary,
                      ),
                      const Spacer(),
                      RatingRow(
                        rating: dish.rating,
                        reviewCount: dish.reviewCount,
                      ),
                    ],
                  ),
                ),
                Gap.h12,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 40),
                  child: Text(dish.name, style: context.text.displaySmall),
                ),
                Gap.h4,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 70),
                  child: Text(dish.tagline, style: context.text.bodyLarge
                      ?.copyWith(color: colors.onSurfaceVariant)),
                ),
                Gap.h16,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FactTile(
                          icon: Icons.schedule_rounded,
                          value: '${dish.prepMinutes} min',
                          label: 'Prep time',
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: _FactTile(
                          icon: Icons.local_fire_department_outlined,
                          value: '${dish.calories}',
                          label: 'Calories',
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: _FactTile(
                          icon: Icons.people_alt_outlined,
                          value: _size?.serves?.split('·').last.trim() ??
                              'Serves 1',
                          label: 'Portion',
                        ),
                      ),
                    ],
                  ),
                ),
                if (dish.tags.isNotEmpty) ...[
                  Gap.h16,
                  Wrap(
                    spacing: Gap.xs,
                    runSpacing: Gap.xs,
                    children: [
                      for (final tag in dish.tags)
                        TagPill(
                          icon: tag.icon,
                          label: tag.label,
                          color: switch (tag) {
                            DishTag.spicy => context.brand.spicy,
                            DishTag.vegetarian => context.brand.veg,
                            DishTag.bestseller => colors.primary,
                            DishTag.chefPick => colors.secondary,
                            DishTag.newItem => colors.tertiary,
                          },
                        ),
                    ],
                  ),
                ],
                Gap.h24,
                Text('About this dish', style: context.text.headlineSmall),
                Gap.h8,
                Text(
                  dish.description,
                  style: context.text.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (dish.sizes.isNotEmpty) ...[
                  Gap.h32,
                  Text('Choose a size', style: context.text.headlineSmall),
                  Gap.h12,
                  for (final size in dish.sizes) ...[
                    _SizeOption(
                      size: size,
                      selected: _size?.id == size.id,
                      basePrice: dish.effectivePrice,
                      onTap: () => setState(() => _size = size),
                    ),
                    Gap.h8,
                  ],
                ],
                if (dish.addOns.isNotEmpty) ...[
                  Gap.h24,
                  Row(
                    children: [
                      Text('Add extras', style: context.text.headlineSmall),
                      Gap.w8,
                      Text('Optional', style: context.text.labelMedium),
                    ],
                  ),
                  Gap.h12,
                  for (final addOn in dish.addOns) ...[
                    _AddOnOption(
                      addOn: addOn,
                      selected: _addOns.contains(addOn.id),
                      onChanged: (value) => setState(() {
                        if (value) {
                          _addOns.add(addOn.id);
                        } else {
                          _addOns.remove(addOn.id);
                        }
                      }),
                    ),
                    Gap.h8,
                  ],
                ],
                Gap.h24,
                Text('Note for the kitchen', style: context.text.headlineSmall),
                Gap.h12,
                TextField(
                  controller: _note,
                  maxLines: 3,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'No onions, extra napkins, ring the top bell…',
                    alignLabelWithHint: true,
                  ),
                ),
                Gap.h24,
                _SimilarDishes(dish: dish),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddBar(
        total: _total,
        quantity: _quantity,
        adding: _adding,
        onDecrement: () => setState(() => _quantity = (_quantity - 1).clamp(1, 20)),
        onIncrement: () => setState(() => _quantity = (_quantity + 1).clamp(1, 20)),
        onAdd: _add,
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(Gap.xs),
      child: Material(
        color: colors.surfaceContainerLowest.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          child: Tooltip(
            message: 'Back',
            child: Icon(
              Icons.arrow_back_rounded,
              size: IconSize.md,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm, horizontal: Gap.xs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: Radii.sm,
      ),
      child: Column(
        children: [
          Icon(icon, size: IconSize.md, color: colors.primary),
          Gap.h4,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall,
          ),
          Text(label, style: context.text.labelSmall),
        ],
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.size,
    required this.selected,
    required this.basePrice,
    required this.onTap,
  });

  final PortionSize size;
  final bool selected;
  final double basePrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      label: '${size.label}, ${money(basePrice + size.priceDelta)}',
      child: ExcludeSemantics(
        child: PressScale(
          scale: 0.985,
          onTap: onTap,
          child: AnimatedContainer(
            duration: Motion.fast,
            curve: Motion.enter,
            constraints: const BoxConstraints(minHeight: kMinTouchTarget + 8),
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: Gap.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primaryContainer
                  : colors.surfaceContainerLowest,
              borderRadius: Radii.sm,
              border: Border.all(
                color: selected ? colors.primary : colors.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: Motion.fast,
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(selected),
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(size.label, style: context.text.titleMedium),
                      if (size.serves != null)
                        Text(size.serves!, style: context.text.bodySmall),
                    ],
                  ),
                ),
                Text(
                  money(basePrice + size.priceDelta),
                  style: context.text.titleMedium?.copyWith(
                    color: selected ? colors.primary : colors.onSurface,
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

class _AddOnOption extends StatelessWidget {
  const _AddOnOption({
    required this.addOn,
    required this.selected,
    required this.onChanged,
  });

  final AddOn addOn;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      checked: selected,
      onTap: () => onChanged(!selected),
      label: '${addOn.label}, plus ${money(addOn.price)}',
      child: ExcludeSemantics(
        child: PressScale(
          scale: 0.985,
          onTap: () => onChanged(!selected),
          child: AnimatedContainer(
            duration: Motion.fast,
            constraints: const BoxConstraints(minHeight: kMinTouchTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.sm,
              vertical: Gap.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: Radii.sm,
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) => onChanged(value ?? false),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
                Expanded(
                  child: Text(addOn.label, style: context.text.bodyLarge),
                ),
                Text(
                  addOn.price == 0 ? 'Free' : '+ ${money(addOn.price)}',
                  style: context.text.titleSmall?.copyWith(
                    color: addOn.price == 0
                        ? context.brand.success
                        : colors.onSurfaceVariant,
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

class _SimilarDishes extends StatelessWidget {
  const _SimilarDishes({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final similar = MenuData.byCategory(dish.categoryId)
        .where((d) => d.id != dish.id)
        .toList();
    if (similar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Goes well with', style: context.text.headlineSmall),
        Gap.h16,
        SizedBox(
          height: 296,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            separatorBuilder: (_, _) => Gap.w12,
            itemBuilder: (context, index) => DishCard(
              dish: similar[index],
              heroPrefix: 'similar-${dish.id}',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => DishDetailScreen(
                    dish: similar[index],
                    heroPrefix: 'similar-${dish.id}',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddBar extends StatelessWidget {
  const _AddBar({
    required this.total,
    required this.quantity,
    required this.adding,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAdd,
  });

  final double total;
  final int quantity;
  final bool adding;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onAdd;

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
              QuantityStepper(
                quantity: quantity,
                min: 1,
                onDecrement: onDecrement,
                onIncrement: onIncrement,
              ),
              Gap.w12,
              Expanded(
                child: AppButton(
                  label: 'Add · ${money(total)}',
                  icon: Icons.add_shopping_cart_rounded,
                  loading: adding,
                  onPressed: onAdd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
