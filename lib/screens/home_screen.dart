import 'dart:async';

import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/dish_cards.dart';
import 'dish_detail_screen.dart';
import 'favourites_screen.dart';
import 'menu_screen.dart';
import 'order_tracking_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final active = state.activeOrder;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        edgeOffset: 96,
        color: context.colors.primary,
        backgroundColor: context.colors.surfaceContainerLowest,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _HomeAppBar(name: state.greetingName, address: state.address),
            const SliverToBoxAdapter(child: Gap.h8),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.md),
                child: FadeSlideIn(child: _SearchEntry()),
              ),
            ),
            if (active != null) ...[
              const SliverToBoxAdapter(child: Gap.h16),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.md),
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: _ActiveOrderBanner(order: active),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: Gap.h24),
            const SliverToBoxAdapter(child: _OfferCarousel()),
            const SliverToBoxAdapter(child: Gap.h32),
            const SliverToBoxAdapter(child: _CategoryStrip()),
            const SliverToBoxAdapter(child: Gap.h32),
            _Rail(
              title: 'Popular right now',
              subtitle: 'What everyone is ordering tonight',
              dishes: MenuData.bestsellers,
              loading: _loading,
              heroPrefix: 'popular',
            ),
            const SliverToBoxAdapter(child: Gap.h32),
            _Rail(
              title: "Chef's table",
              subtitle: 'Hand-picked by our head chef',
              dishes: MenuData.chefPicks,
              loading: _loading,
              heroPrefix: 'chef',
            ),
            const SliverToBoxAdapter(child: Gap.h32),
            if (MenuData.onOffer.isNotEmpty) ...[
              _Rail(
                title: 'On offer today',
                subtitle: 'Discounts end at midnight',
                dishes: MenuData.onOffer,
                loading: _loading,
                heroPrefix: 'offer',
              ),
              const SliverToBoxAdapter(child: Gap.h32),
            ],
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.md),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Top rated',
                  subtitle: 'Highest scores across the whole menu',
                  actionLabel: 'Full menu',
                  onAction: () => goToShellTab(ShellTab.menu),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap.h16),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.md),
              sliver: SliverList.separated(
                itemCount: _loading ? 3 : MenuData.trending.length,
                separatorBuilder: (_, _) => Gap.h12,
                itemBuilder: (context, index) {
                  if (_loading) {
                    return const SoftCard(
                      child: SizedBox(height: 104, child: Skeleton(height: 104)),
                    );
                  }
                  final dish = MenuData.trending[index];
                  return FadeSlideIn.staggered(
                    key: ValueKey(dish.id),
                    index: index,
                    child: DishRow(
                      dish: dish,
                      heroPrefix: 'top',
                      onTap: () => openDish(context, dish, heroPrefix: 'top'),
                      onAdd: () => quickAdd(context, dish),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: Gap.h32),
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
                  child: Text(
                    '${MenuData.dishes.length} dishes · '
                    '${MenuData.categories.length} categories\n'
                    '${MenuData.restaurantTagline}',
                    textAlign: TextAlign.center,
                    style: context.text.labelMedium,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap.h40),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.name, required this.address});

  final String name;
  final DeliveryAddress address;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final favourites = AppScope.of(context).favouriteCount;

    return SliverAppBar(
      pinned: true,
      toolbarHeight: 76,
      backgroundColor: colors.surface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hello, $name',
            style: context.text.headlineMedium,
            overflow: TextOverflow.ellipsis,
          ),
          Gap.h4,
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 15,
                color: colors.primary,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  address.line,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Favourites',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FavouritesScreen()),
          ),
          icon: Badge(
            isLabelVisible: favourites > 0,
            label: Text('$favourites'),
            backgroundColor: colors.error,
            textColor: colors.onError,
            child: const Icon(Icons.favorite_border_rounded),
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => showAppSnack('You are all caught up — no new notifications.',
            icon: Icons.notifications_none_rounded,
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Gap.w4,
      ],
    );
  }
}

class _SearchEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: 'Search the menu',
      child: ExcludeSemantics(
        child: PressScale(
          scale: 0.985,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          child: Hero(
            tag: 'search-field',
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: Gap.md),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: Radii.sm,
                  border: Border.all(color: colors.outline),
                  boxShadow: Shadows.card(Theme.of(context).brightness),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                    Gap.w12,
                    Expanded(
                      child: Text(
                        'Search dishes, categories, tags…',
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: Radii.xs,
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: IconSize.sm,
                        color: colors.onPrimaryContainer,
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

class _ActiveOrderBanner extends StatelessWidget {
  const _ActiveOrderBanner({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = (order.stage.index + 1) / OrderStage.values.length;

    return PressScale(
      scale: 0.985,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: order.id),
        ),
      ),
      child: SoftCard(
        color: colors.secondaryContainer,
        bordered: false,
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: Radii.sm,
              ),
              child: Icon(
                order.stage.icon,
                color: colors.onSecondary,
                size: IconSize.lg,
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.stage.title,
                    style: context.text.titleMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    'Order ${order.id} · ${order.itemCount} items',
                    style: context.text.bodySmall?.copyWith(
                      color: colors.onSecondaryContainer,
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
                        minHeight: 5,
                        backgroundColor: colors.onSecondaryContainer
                            .withValues(alpha: 0.18),
                        color: colors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap.w8,
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCarousel extends StatefulWidget {
  const _OfferCarousel();

  @override
  State<_OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<_OfferCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.86);
  Timer? _timer;
  int _page = 0;

  static const List<({String title, String subtitle, IconData icon})> _offers = [
    (
      title: '20% off tonight',
      subtitle: 'Use SAVORA20 at checkout on any order above EGP 250.',
      icon: Icons.local_offer_rounded,
    ),
    (
      title: 'Free delivery',
      subtitle: 'On every order over EGP 400. No code needed.',
      icon: Icons.delivery_dining_rounded,
    ),
    (
      title: 'New: Frutti di Mare',
      subtitle: 'Gulf shrimp and calamari, straight from the wood oven.',
      icon: Icons.set_meal_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      if (Motion.reduced(context)) return;
      _controller.animateToPage(
        (_page + 1) % _offers.length,
        duration: Motion.slow,
        curve: Motion.emphasized,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _controller,
            itemCount: _offers.length,
            padEnds: false,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) {
              final offer = _offers[index];
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  index == 0 ? Gap.md : Gap.xs,
                  0,
                  Gap.xs,
                  0,
                ),
                child: OfferCard(
                  title: offer.title,
                  subtitle: offer.subtitle,
                  icon: offer.icon,
                  onTap: () => goToShellTab(ShellTab.menu),
                ),
              );
            },
          ),
        ),
        Gap.h12,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _offers.length; i++)
              AnimatedContainer(
                duration: Motion.base,
                curve: Motion.enter,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == _page ? 20 : 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? context.colors.primary
                      : context.colors.outline,
                  borderRadius: Radii.pill,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Gap.md),
          child: SectionHeader(title: 'Browse by category'),
        ),
        Gap.h16,
        SizedBox(
          height: kMinTouchTarget + 4,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Gap.md),
            itemCount: MenuData.categories.length,
            separatorBuilder: (_, _) => Gap.w8,
            itemBuilder: (context, index) {
              final category = MenuData.categories[index];
              return FadeSlideIn.staggered(
                index: index,
                offset: 0,
                child: CategoryChip(
                  category: category,
                  selected: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MenuScreen(initialCategoryId: category.id),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.title,
    required this.subtitle,
    required this.dishes,
    required this.loading,
    required this.heroPrefix,
  });

  final String title;
  final String subtitle;
  final List<Dish> dishes;
  final bool loading;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.md),
            child: SectionHeader(
              title: title,
              subtitle: subtitle,
              actionLabel: 'See all',
              onAction: () => goToShellTab(ShellTab.menu),
            ),
          ),
          Gap.h16,
          SizedBox(
            height: 296,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.md),
              itemCount: loading ? 3 : dishes.length,
              separatorBuilder: (_, _) => Gap.w12,
              itemBuilder: (context, index) {
                if (loading) return const DishCardSkeleton();
                final dish = dishes[index];
                return FadeSlideIn.staggered(
                  key: ValueKey('$heroPrefix-${dish.id}'),
                  index: index,
                  offset: 0,
                  child: DishCard(
                    dish: dish,
                    heroPrefix: heroPrefix,
                    onTap: () => openDish(context, dish, heroPrefix: heroPrefix),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
