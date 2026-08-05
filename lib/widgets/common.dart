import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../core/tokens.dart';

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final reduced = Motion.reduced(context);

    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap?.call();
              }
            : null,
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                widget.onLongPress!.call();
              },
        child: AnimatedScale(
          scale: _pressed && !reduced ? widget.scale : 1,
          duration: _pressed ? Motion.instant : Motion.base,
          curve: _pressed ? Curves.easeOut : Motion.pop,
          child: widget.child,
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 22,
    this.duration = Motion.slow,
  });

  factory FadeSlideIn.staggered({
    Key? key,
    required int index,
    required Widget child,
    double offset = 22,
  }) {
    final steps = index.clamp(0, 8);
    return FadeSlideIn(
      key: key,
      delay: Motion.stagger * steps,
      offset: offset,
      child: child,
    );
  }

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;

    final curved = CurvedAnimation(parent: _controller, curve: Motion.enter);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - curved.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.tone = AppButtonTone.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final AppButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      AppButtonTone.primary => (colors.primary, colors.onPrimary),
      AppButtonTone.neutral => (colors.surfaceContainerHighest, colors.onSurface),
      AppButtonTone.danger => (colors.error, colors.onError),
    };

    final disabled = onPressed == null || loading;

    final button = FilledButton(
      onPressed: disabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size.fromHeight(54),
      ),
      child: AnimatedSwitcher(
        duration: Motion.fast,
        child: loading
            ? SizedBox(
                key: const ValueKey('busy'),
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(foreground),
                ),
              )
            : Row(
                key: const ValueKey('idle'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: IconSize.md),
                    Gap.w8,
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelLarge?.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
      ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      onTap: disabled ? null : onPressed,
      label: loading ? '$label, in progress' : label,
      child: ExcludeSemantics(
        child: expand ? SizedBox(width: double.infinity, child: button) : button,
      ),
    );
  }
}

enum AppButtonTone { primary, neutral, danger }

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.headlineMedium),
              if (subtitle != null) ...[
                Gap.h4,
                Text(subtitle!, style: context.text.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          Gap.w8,
          TextButton(
            onPressed: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel!),
                const Icon(Icons.chevron_right_rounded, size: IconSize.sm),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.xl),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 104,
                width: 104,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 44, color: colors.primary),
              ),
              Gap.h24,
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.text.headlineMedium,
              ),
              Gap.h8,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                Gap.h24,
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.md),
    this.radius = Radii.md,
    this.color,
    this.bordered = true,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? color;
  final bool bordered;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surfaceContainerLowest,
        borderRadius: radius,
        border: bordered ? Border.all(color: colors.outlineVariant) : null,
        boxShadow: elevated ? Shadows.card(brightness) : null,
      ),
      child: child,
    );
  }
}

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.height = 16,
    this.width,
    this.radius = Radii.xs,
  });

  final double height;
  final double? width;
  final BorderRadius radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = colors.surfaceContainerHigh;
    final highlight = colors.surfaceContainerHighest;

    if (Motion.reduced(context)) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(color: base, borderRadius: widget.radius),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = _controller.value * 2 - 1;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.radius,
            gradient: LinearGradient(
              begin: Alignment(shift - 1, 0),
              end: Alignment(shift + 1, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Gap.xs : Gap.sm,
        vertical: compact ? 3 : Gap.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: Radii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : IconSize.sm - 4, color: tint),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (compact ? context.text.labelSmall : context.text.labelMedium)
                      ?.copyWith(color: tint, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({super.key, required this.value, this.style});

  final double value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value, end: value),
      duration: Motion.base,
      curve: Motion.enter,
      builder: (context, animated, _) => Text(
        money(animated),
        style: style ?? context.text.titleLarge,
      ),
    );
  }
}

class HairLine extends StatelessWidget {
  const HairLine({super.key, this.indent = 0});
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      color: context.colors.outlineVariant,
    );
  }
}

void showAppSnack(
  String message, {
  IconData icon = Icons.check_circle_rounded,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = appMessengerKey.currentState;
  final messengerContext = appMessengerKey.currentContext;
  if (messenger == null || messengerContext == null) return;

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 4),
      content: Row(
        children: [
          Icon(
            icon,
            size: IconSize.md,
            color: Theme.of(messengerContext).colorScheme.inversePrimary,
          ),
          Gap.w12,
          Expanded(child: Text(message)),
        ],
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
    ),
  );
}
