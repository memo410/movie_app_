import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../state/app_state.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const List<_NavItem> _items = [
  _NavItem('Home', Icons.home_outlined, Icons.home_rounded),
  _NavItem(
    'Menu',
    Icons.restaurant_menu_outlined,
    Icons.restaurant_menu_rounded,
  ),
  _NavItem('Cart', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
  _NavItem('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
  _NavItem('Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  @override
  void initState() {
    super.initState();
    shellTabIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    shellTabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  void _select(int index) {
    if (shellTabIndex.value == index) return;
    HapticFeedback.selectionClick();
    shellTabIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final index = shellTabIndex.value;

    return PopScope(
      canPop: index == ShellTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(ShellTab.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: const [
            HomeScreen(),
            MenuScreen(),
            CartScreen(),
            OrdersScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _BottomNav(index: index, onSelect: _select),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onSelect});

  final int index;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cartCount = AppScope.of(context).cartCount;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
        boxShadow: Shadows.card(Theme.of(context).brightness),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: i == index,
                    badge: i == ShellTab.cart ? cartCount : 0,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = selected ? colors.primary : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      label: badge > 0 ? '${item.label}, $badge items' : item.label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.sm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: Motion.fast,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween<double>(begin: 0.82, end: 1).animate(
                        CurvedAnimation(parent: animation, curve: Motion.pop),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      selected ? item.activeIcon : item.icon,
                      key: ValueKey(selected),
                      size: IconSize.lg,
                      color: tint,
                    ),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -8,
                      top: -5,
                      child: _CartBadge(count: badge),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: Motion.fast,
                style: context.text.labelSmall!.copyWith(
                  color: tint,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
                child: Text(item.label),
              ),
              AnimatedContainer(
                duration: Motion.base,
                curve: Motion.enter,
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: selected ? 20 : 0,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: Radii.pill,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TweenAnimationBuilder<double>(
      key: ValueKey(count),
      tween: Tween(begin: 0.6, end: 1),
      duration: Motion.base,
      curve: Motion.pop,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        constraints: const BoxConstraints(minWidth: 19),
        height: 19,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: Radii.pill,
          border: Border.all(color: colors.surfaceContainerLowest, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 99 ? '99+' : '$count',
          style: context.text.labelSmall?.copyWith(
            color: colors.onError,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
