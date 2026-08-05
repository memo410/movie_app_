import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/dish_cards.dart';
import 'dish_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() => _searching = value.trim().isNotEmpty);
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {
        _query = value;
        _searching = false;
      });
      if (value.trim().length >= 2) {
        AppScope.read(context).recordSearch(value);
      }
    });
  }

  void _runSearch(String term) {
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    _focus.unfocus();
    setState(() {
      _query = term;
      _searching = false;
    });
    AppScope.read(context).recordSearch(term);
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _query = '';
      _searching = false;
    });
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final results = state.search(_query);
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.xs, Gap.xs, Gap.md, Gap.xs),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Hero(
                      tag: 'search-field',
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          textInputAction: TextInputAction.search,
                          onChanged: _onChanged,
                          onSubmitted: _runSearch,
                          decoration: InputDecoration(
                            hintText: 'Search dishes, categories, tags…',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: hasQuery || _controller.text.isNotEmpty
                                ? IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: _clear,
                                    icon: const Icon(Icons.close_rounded),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Motion.base,
                child: _searching
                    ? const _SearchingList(key: ValueKey('searching'))
                    : !hasQuery
                        ? _Suggestions(
                            key: const ValueKey('suggestions'),
                            recent: state.recentSearches,
                            onPick: _runSearch,
                            onClearRecent: state.clearRecentSearches,
                          )
                        : results.isEmpty
                            ? EmptyState(
                                key: const ValueKey('empty'),
                                icon: Icons.search_off_rounded,
                                title: 'No dish matches “${_query.trim()}”',
                                message:
                                    'Check the spelling, or try a broader word '
                                    'like “pizza”, “spicy” or “dessert”.',
                                actionLabel: 'Clear search',
                                onAction: _clear,
                              )
                            : _Results(
                                key: ValueKey('results-$_query'),
                                dishes: results,
                                query: _query.trim(),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchingList extends StatelessWidget {
  const _SearchingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Gap.md),
      itemCount: 4,
      separatorBuilder: (_, _) => Gap.h12,
      itemBuilder: (context, index) => const SoftCard(
        child: SizedBox(height: 104, child: Skeleton(height: 104)),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({
    super.key,
    required this.recent,
    required this.onPick,
    required this.onClearRecent,
  });

  final List<String> recent;
  final ValueChanged<String> onPick;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xxl),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text('Recent searches', style: context.text.titleMedium),
              ),
              TextButton(onPressed: onClearRecent, child: const Text('Clear')),
            ],
          ),
          Gap.h8,
          for (final term in recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded),
              title: Text(term, style: context.text.bodyLarge),
              trailing: const Icon(Icons.north_west_rounded, size: IconSize.sm),
              onTap: () => onPick(term),
            ),
          Gap.h24,
        ],
        Text('Popular right now', style: context.text.titleMedium),
        Gap.h12,
        Wrap(
          spacing: Gap.xs,
          runSpacing: Gap.xs,
          children: [
            for (final term in MenuData.popularSearches)
              ActionChip(
                avatar: const Icon(Icons.trending_up_rounded, size: IconSize.sm),
                label: Text(term),
                onPressed: () => onPick(term),
              ),
          ],
        ),
        Gap.h32,
        Text('Browse categories', style: context.text.titleMedium),
        Gap.h12,
        Wrap(
          spacing: Gap.xs,
          runSpacing: Gap.xs,
          children: [
            for (final category in MenuData.categories)
              ActionChip(
                avatar: Icon(category.icon, size: IconSize.sm),
                label: Text(category.name),
                onPressed: () => onPick(category.name),
              ),
          ],
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({super.key, required this.dishes, required this.query});

  final List<Dish> dishes;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xs),
          child: Text(
            '${dishes.length} ${dishes.length == 1 ? "result" : "results"} '
            'for “$query”',
            style: context.text.labelMedium,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xxl),
            itemCount: dishes.length,
            separatorBuilder: (_, _) => Gap.h12,
            itemBuilder: (context, index) {
              final dish = dishes[index];
              return FadeSlideIn.staggered(
                key: ValueKey('search-${dish.id}'),
                index: index,
                child: DishRow(
                  dish: dish,
                  heroPrefix: 'search',
                  onTap: () => openDish(context, dish, heroPrefix: 'search'),
                  onAdd: () => quickAdd(context, dish),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
