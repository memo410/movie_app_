import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'favourites_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.logout_rounded, color: context.colors.error),
        title: const Text('Sign out?'),
        content: const Text(
          'Your cart, favourites and order history are stored on this device '
          'only and will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay signed in'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    AppScope.read(context).signOut();
    shellTabIndex.value = ShellTab.home;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.xxl),
        children: [
          FadeSlideIn(child: _ProfileHeader(state: state)),
          Gap.h20,
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt_long_rounded,
                    value: '${state.orders.length}',
                    label: 'Orders',
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_rounded,
                    value: '${state.favouriteCount}',
                    label: 'Favourites',
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_bag_rounded,
                    value: '${state.cartCount}',
                    label: 'In cart',
                  ),
                ),
              ],
            ),
          ),
          Gap.h32,
          Text('Appearance', style: context.text.headlineSmall),
          Gap.h12,
          _ThemePicker(state: state),
          Gap.h32,
          Text('Account', style: context.text.headlineSmall),
          Gap.h12,
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.favorite_border_rounded,
                title: 'Favourites',
                subtitle: '${state.favouriteCount} saved dishes',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavouritesScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Delivery addresses',
                subtitle: state.address.line,
                onTap: () => _pickAddress(context, state),
              ),
              _SettingsTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment methods',
                subtitle: state.payment.label,
                onTap: () => _pickPayment(context, state),
              ),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Order updates and offers',
                onTap: () => showAppSnack(
                  'Notification settings are not available in this build.',
                  icon: Icons.info_outline_rounded,
                ),
              ),
            ],
          ),
          Gap.h32,
          Text('Support', style: context.text.headlineSmall),
          Gap.h12,
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help centre',
                subtitle: 'FAQs and contact options',
                onTap: () => showAppSnack(
                  'The help centre is not available in this build.',
                  icon: Icons.info_outline_rounded,
                ),
              ),
              _SettingsTile(
                icon: Icons.storefront_outlined,
                title: 'About ${MenuData.restaurantName}',
                subtitle: MenuData.restaurantTagline,
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: MenuData.restaurantName,
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'A Flutter demo restaurant app. All data is hardcoded '
                      'and stored in memory only.',
                ),
              ),
            ],
          ),
          Gap.h32,
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.error,
              side: BorderSide(color: context.colors.error),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
          Gap.h24,
          Center(
            child: Text(
              '${MenuData.restaurantName} · version 1.0.0',
              style: context.text.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  void _pickAddress(BuildContext context, AppState state) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _PickerSheet(
        title: 'Delivery address',
        children: [
          for (final address in MenuData.addresses)
            _PickerOption(
              icon: address.icon,
              title: address.label,
              subtitle: address.line,
              selected: state.address.id == address.id,
              onTap: () {
                state.setAddress(address);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    );
  }

  void _pickPayment(BuildContext context, AppState state) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _PickerSheet(
        title: 'Payment method',
        children: [
          for (final method in MenuData.paymentMethods)
            _PickerOption(
              icon: method.icon,
              title: method.label,
              subtitle: method.detail,
              selected: state.payment.id == method.id,
              onTap: () {
                state.setPayment(method);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final initials = state.userName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Container(
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
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Text(
              initials.isEmpty ? 'G' : initials,
              style: context.text.headlineMedium?.copyWith(color: Colors.white),
            ),
          ),
          Gap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  state.userEmail.isEmpty
                      ? 'Browsing as a guest'
                      : state.userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm, horizontal: Gap.xs),
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary, size: IconSize.lg),
          Gap.h4,
          Text(value, style: context.text.headlineSmall),
          Text(label, style: context.text.labelSmall),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.state});

  final AppState state;

  static const List<({ThemeMode mode, String label, IconData icon})> _modes = [
    (mode: ThemeMode.light, label: 'Light', icon: Icons.light_mode_rounded),
    (mode: ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_rounded),
    (
      mode: ThemeMode.system,
      label: 'System',
      icon: Icons.brightness_auto_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        for (var i = 0; i < _modes.length; i++) ...[
          Expanded(
            child: Semantics(
              button: true,
              selected: state.themeMode == _modes[i].mode,
              onTap: () => state.setThemeMode(_modes[i].mode),
              label: '${_modes[i].label} theme',
              child: ExcludeSemantics(
                child: PressScale(
                  scale: 0.95,
                  onTap: () => state.setThemeMode(_modes[i].mode),
                  child: AnimatedContainer(
                    duration: Motion.base,
                    curve: Motion.enter,
                    padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                    decoration: BoxDecoration(
                      color: state.themeMode == _modes[i].mode
                          ? colors.primary
                          : colors.surfaceContainerLowest,
                      borderRadius: Radii.sm,
                      border: Border.all(
                        color: state.themeMode == _modes[i].mode
                            ? colors.primary
                            : colors.outline,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _modes[i].icon,
                          color: state.themeMode == _modes[i].mode
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                        Gap.h4,
                        Text(
                          _modes[i].label,
                          style: context.text.labelMedium?.copyWith(
                            color: state.themeMode == _modes[i].mode
                                ? colors.onPrimary
                                : colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (i < _modes.length - 1) Gap.w12,
        ],
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const HairLine(indent: 56),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minVerticalPadding: Gap.sm,
      leading: Icon(icon, color: context.colors.primary),
      title: Text(title, style: context.text.titleMedium),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      onTap: onTap,
      selected: selected,
      minVerticalPadding: Gap.sm,
      shape: const RoundedRectangleBorder(borderRadius: Radii.sm),
      selectedTileColor: colors.primaryContainer,
      leading: Icon(
        icon,
        color: selected ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(title, style: context.text.titleMedium),
      subtitle: Text(subtitle, style: context.text.bodySmall),
      trailing: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? colors.primary : colors.onSurfaceVariant,
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: context.text.headlineMedium),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Gap.h8,
            ...children,
          ],
        ),
      ),
    );
  }
}
