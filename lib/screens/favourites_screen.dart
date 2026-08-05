import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../core/tokens.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/dish_cards.dart';
import 'dish_detail_screen.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final favourites = state.favourites;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900 ? 4 : (width >= 620 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          favourites.isEmpty
              ? 'Favourites'
              : 'Favourites · ${favourites.length}',
        ),
      ),
      body: favourites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No favourites yet',
              message:
                  'Tap the heart on any dish and it will show up here, ready '
                  'to reorder in one tap.',
              actionLabel: 'Browse the menu',
              onAction: () => goToShellTab(ShellTab.menu),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.xxl),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: Gap.sm,
                crossAxisSpacing: Gap.sm,
                mainAxisExtent: 296,
              ),
              itemCount: favourites.length,
              itemBuilder: (context, index) {
                final dish = favourites[index];
                return FadeSlideIn.staggered(
                  key: ValueKey('fav-${dish.id}'),
                  index: index,
                  child: DishCard(
                    dish: dish,
                    width: double.infinity,
                    heroPrefix: 'fav',
                    onTap: () => openDish(context, dish, heroPrefix: 'fav'),
                  ),
                );
              },
            ),
      bottomNavigationBar: favourites.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Gap.md),
                child: AppButton(
                  label: 'Add all ${favourites.length} to cart',
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: () {
                    for (final dish in favourites) {
                      state.addToCart(
                        dish,
                        size: dish.sizes.isEmpty
                            ? null
                            : dish.sizes[dish.sizes.length ~/ 2],
                      );
                    }
                    showAppSnack(
                      '${favourites.length} favourites added to your cart',
                      icon: Icons.shopping_bag_rounded,
                      actionLabel: 'View cart',
                      onAction: () => goToShellTab(ShellTab.cart),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
