import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import '../widgets/dish_cards.dart';
import 'dish_detail_screen.dart';
import 'search_screen.dart';

enum MenuSort {
  popular('Most popular', Icons.local_fire_department_rounded),
  rating('Highest rated', Icons.star_rounded),
  priceLow('Price: low to high', Icons.arrow_upward_rounded),
  priceHigh('Price: high to low', Icons.arrow_downward_rounded),
  quickest('Ready quickest', Icons.bolt_rounded);

  const MenuSort(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum MenuFilter {
  vegetarian('Vegetarian', Icons.eco_rounded),
  spicy('Spicy', Icons.whatshot_rounded),
  offers('On offer', Icons.local_offer_rounded),
  budget('Under EGP 150', Icons.savings_rounded),
  quick('Under 15 min', Icons.timer_outlined);

  const MenuFilter(this.label, this.icon);
  final String label;
  final IconData icon;
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late String? _categoryId = widget.initialCategoryId;
  MenuSort _sort = MenuSort.popular;
  final Set<MenuFilter> _filters = {};
  bool _gridView = false;

  List<Dish> get _results {
    var list = _categoryId == null
        ? [...MenuData.dishes]
        : MenuData.byCategory(_categoryId!);

    for (final filter in _filters) {
      list = list
          .where((d) => switch (filter) {
                MenuFilter.vegetarian => d.tags.contains(DishTag.vegetarian),
                MenuFilter.spicy => d.tags.contains(DishTag.spicy),
                MenuFilter.offers => d.isDiscounted,
                MenuFilter.budget => d.effectivePrice < 150,
                MenuFilter.quick => d.prepMinutes < 15,
              })
          .toList();
    }

    list.sort((a, b) => switch (_sort) {
          MenuSort.popular => b.reviewCount.compareTo(a.reviewCount),
          MenuSort.rating => b.rating.compareTo(a.rating),
          MenuSort.priceLow => a.effectivePrice.compareTo(b.effectivePrice),
          MenuSort.priceHigh => b.effectivePrice.compareTo(a.effectivePrice),
          MenuSort.quickest => a.prepMinutes.compareTo(b.prepMinutes),
        });

    return list;
  }

  Future<void> _openSortSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _SortSheet(
        sort: _sort,
        filters: _filters,
        onApply: (sort, filters) {
          setState(() {
            _sort = sort;
            _filters
              ..clear()
              ..addAll(filters);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final isPushed = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _MenuHeader(
              isPushed: isPushed,
              gridView: _gridView,
              activeFilters: _filters.length,
              onToggleView: () => setState(() => _gridView = !_gridView),
              onOpenFilters: _openSortSheet,
            ),
            _CategoryTabs(
              selectedId: _categoryId,
              onSelect: (id) => setState(() => _categoryId = id),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${results.length} '
                      '${results.length == 1 ? "dish" : "dishes"}'
                      '${_categoryId == null ? "" : " in "
                          "${MenuData.categoryById(_categoryId!).name}"}',
                      style: context.text.labelMedium,
                    ),
                  ),
                  TagPill(icon: _sort.icon, label: _sort.label, compact: true),
                ],
              ),
            ),
            if (_filters.isNotEmpty)
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Gap.md),
                  children: [
                    for (final filter in _filters)
                      Padding(
                        padding: const EdgeInsets.only(right: Gap.xs),
                        child: InputChip(
                          avatar: Icon(filter.icon, size: IconSize.sm),
                          label: Text(filter.label),
                          onDeleted: () =>
                              setState(() => _filters.remove(filter)),
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        ),
                      ),
                    TextButton(
                      onPressed: () => setState(_filters.clear),
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: results.isEmpty
                  ? EmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      title: 'Nothing matches those filters',
                      message: 'Try removing a filter or switching to another '
                          'category — there are ${MenuData.dishes.length} '
                          'dishes on the full menu.',
                      actionLabel: 'Clear filters',
                      onAction: () => setState(() {
                        _filters.clear();
                        _categoryId = null;
                      }),
                    )
                  : _gridView
                      ? _DishGrid(dishes: results)
                      : _DishList(dishes: results),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.isPushed,
    required this.gridView,
    required this.activeFilters,
    required this.onToggleView,
    required this.onOpenFilters,
  });

  final bool isPushed;
  final bool gridView;
  final int activeFilters;
  final VoidCallback onToggleView;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.xs, 0),
      child: Row(
        children: [
          if (isPushed)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
          Expanded(
            child: Text(
              'Our menu',
              style: context.text.headlineLarge,
            ),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: gridView ? 'Switch to list view' : 'Switch to grid view',
            onPressed: onToggleView,
            icon: AnimatedSwitcher(
              duration: Motion.fast,
              child: Icon(
                gridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                key: ValueKey(gridView),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sort and filter',
            onPressed: onOpenFilters,
            icon: Badge(
              isLabelVisible: activeFilters > 0,
              label: Text('$activeFilters'),
              backgroundColor: colors.primary,
              textColor: colors.onPrimary,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selectedId, required this.onSelect});

  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kMinTouchTarget + 12,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.xs),
        children: [
          CategoryChip(
            category: const MenuCategory(
              id: 'all',
              name: 'Everything',
              icon: Icons.restaurant_rounded,
            ),
            selected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          for (final category in MenuData.categories) ...[
            Gap.w8,
            CategoryChip(
              category: category,
              selected: selectedId == category.id,
              onTap: () => onSelect(category.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _DishList extends StatelessWidget {
  const _DishList({required this.dishes});

  final List<Dish> dishes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xxl),
      itemCount: dishes.length,
      separatorBuilder: (_, __) => Gap.h12,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return FadeSlideIn.staggered(
          key: ValueKey('menu-${dish.id}'),
          index: index,
          child: DishRow(
            dish: dish,
            heroPrefix: 'menu',
            onTap: () => openDish(context, dish, heroPrefix: 'menu'),
            onAdd: () => quickAdd(context, dish),
          ),
        );
      },
    );
  }
}

class _DishGrid extends StatelessWidget {
  const _DishGrid({required this.dishes});

  final List<Dish> dishes;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900 ? 4 : (width >= 620 ? 3 : 2);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xxl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: Gap.sm,
        crossAxisSpacing: Gap.sm,
        mainAxisExtent: 296,
      ),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return FadeSlideIn.staggered(
          key: ValueKey('grid-${dish.id}'),
          index: index,
          child: DishCard(
            dish: dish,
            width: double.infinity,
            heroPrefix: 'grid',
            onTap: () => openDish(context, dish, heroPrefix: 'grid'),
          ),
        );
      },
    );
  }
}

class _SortSheet extends StatefulWidget {
  const _SortSheet({
    required this.sort,
    required this.filters,
    required this.onApply,
  });

  final MenuSort sort;
  final Set<MenuFilter> filters;
  final void Function(MenuSort sort, Set<MenuFilter> filters) onApply;

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late MenuSort _sort = widget.sort;
  late final Set<MenuFilter> _filters = {...widget.filters};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sort and filter',
                      style: context.text.headlineMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Gap.h16,
              Text('Sort by', style: context.text.titleMedium),
              Gap.h12,
              Wrap(
                spacing: Gap.xs,
                runSpacing: Gap.xs,
                children: [
                  for (final option in MenuSort.values)
                    ChoiceChip(
                      avatar: Icon(
                        option.icon,
                        size: IconSize.sm,
                        color: _sort == option
                            ? context.colors.onPrimary
                            : context.colors.onSurfaceVariant,
                      ),
                      label: Text(option.label),
                      selected: _sort == option,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _sort = option),
                    ),
                ],
              ),
              Gap.h24,
              Text('Filter by', style: context.text.titleMedium),
              Gap.h12,
              Wrap(
                spacing: Gap.xs,
                runSpacing: Gap.xs,
                children: [
                  for (final filter in MenuFilter.values)
                    FilterChip(
                      avatar: Icon(
                        filter.icon,
                        size: IconSize.sm,
                        color: _filters.contains(filter)
                            ? context.colors.onPrimary
                            : context.colors.onSurfaceVariant,
                      ),
                      label: Text(filter.label),
                      selected: _filters.contains(filter),
                      showCheckmark: false,
                      onSelected: (value) => setState(() {
                        if (value) {
                          _filters.add(filter);
                        } else {
                          _filters.remove(filter);
                        }
                      }),
                    ),
                ],
              ),
              Gap.h32,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _filters.clear();
                        _sort = MenuSort.popular;
                      }),
                      child: const Text('Reset'),
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Show results',
                      onPressed: () {
                        widget.onApply(_sort, _filters);
                        Navigator.of(context).pop();
                      },
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
