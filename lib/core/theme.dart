import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.success,
    required this.onSuccess,
    required this.successSurface,
    required this.rating,
    required this.spicy,
    required this.veg,
    required this.heroStart,
    required this.heroEnd,
    required this.scrim,
  });

  final Color success;
  final Color onSuccess;
  final Color successSurface;
  final Color rating;
  final Color spicy;
  final Color veg;
  final Color heroStart;
  final Color heroEnd;
  final Color scrim;

  static const BrandColors light = BrandColors(
    success: Color(0xFF15803D),
    onSuccess: Color(0xFFFFFFFF),
    successSurface: Color(0xFFDCFCE7),
    rating: Color(0xFFD97706),
    spicy: Color(0xFFDC2626),
    veg: Color(0xFF15803D),
    heroStart: Color(0xFFF97316),
    heroEnd: Color(0xFFC2410C),
    scrim: Color(0x8C1C1917),
  );

  static const BrandColors dark = BrandColors(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF052E16),
    successSurface: Color(0xFF14301F),
    rating: Color(0xFFFBBF24),
    spicy: Color(0xFFF87171),
    veg: Color(0xFF4ADE80),
    heroStart: Color(0xFFEA580C),
    heroEnd: Color(0xFF7C2D12),
    scrim: Color(0xB3000000),
  );

  @override
  BrandColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successSurface,
    Color? rating,
    Color? spicy,
    Color? veg,
    Color? heroStart,
    Color? heroEnd,
    Color? scrim,
  }) {
    return BrandColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successSurface: successSurface ?? this.successSurface,
      rating: rating ?? this.rating,
      spicy: spicy ?? this.spicy,
      veg: veg ?? this.veg,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      rating: Color.lerp(rating, other.rating, t)!,
      spicy: Color.lerp(spicy, other.spicy, t)!,
      veg: Color.lerp(veg, other.veg, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

extension BrandTheme on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  BrandColors get brand => Theme.of(this).extension<BrandColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

abstract final class AppTheme {
  static const ColorScheme _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFC2410C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFEDD5),
    onPrimaryContainer: Color(0xFF7C2D12),
    secondary: Color(0xFF2563EB),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDBEAFE),
    onSecondaryContainer: Color(0xFF1E3A8A),
    tertiary: Color(0xFF9A3412),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE4CC),
    onTertiaryContainer: Color(0xFF7C2D12),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: Color(0xFFFFF7ED),
    onSurface: Color(0xFF1C1917),
    onSurfaceVariant: Color(0xFF6B6257),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFBF5),
    surfaceContainer: Color(0xFFFDF4F0),
    surfaceContainerHigh: Color(0xFFF9EBE1),
    surfaceContainerHighest: Color(0xFFF4E2D5),
    outline: Color(0xFFD9C4B3),
    outlineVariant: Color(0xFFF0DECE),
    inverseSurface: Color(0xFF2C2622),
    onInverseSurface: Color(0xFFFFF7ED),
    inversePrimary: Color(0xFFFDBA74),
    shadow: Color(0xFF1C1917),
    scrim: Color(0xFF000000),
  );

  static const ColorScheme _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFB923C),
    onPrimary: Color(0xFF451A03),
    primaryContainer: Color(0xFF7C2D12),
    onPrimaryContainer: Color(0xFFFFEDD5),
    secondary: Color(0xFF60A5FA),
    onSecondary: Color(0xFF0B2545),
    secondaryContainer: Color(0xFF1E3A8A),
    onSecondaryContainer: Color(0xFFDBEAFE),
    tertiary: Color(0xFFFDBA74),
    onTertiary: Color(0xFF431407),
    tertiaryContainer: Color(0xFF7C2D12),
    onTertiaryContainer: Color(0xFFFFE4CC),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: Color(0xFF0C0A09),
    onSurface: Color(0xFFFAFAF9),
    onSurfaceVariant: Color(0xFFA8A29E),
    surfaceContainerLowest: Color(0xFF090807),
    surfaceContainerLow: Color(0xFF16130F),
    surfaceContainer: Color(0xFF1C1917),
    surfaceContainerHigh: Color(0xFF262220),
    surfaceContainerHighest: Color(0xFF302B28),
    outline: Color(0xFF57504A),
    outlineVariant: Color(0xFF332E2B),
    inverseSurface: Color(0xFFFAFAF9),
    onInverseSurface: Color(0xFF1C1917),
    inversePrimary: Color(0xFFC2410C),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static TextTheme _typography(Color onSurface, Color muted) {
    final display = GoogleFonts.playfairDisplayTextTheme();
    final body = GoogleFonts.karlaTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge!.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
        color: onSurface,
      ),
      displayMedium: display.displayMedium!.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      displaySmall: display.displaySmall!.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: onSurface,
      ),
      headlineLarge: display.headlineLarge!.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: onSurface,
      ),
      headlineMedium: display.headlineMedium!.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),
      headlineSmall: display.headlineSmall!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),
      titleLarge: body.titleLarge!.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: onSurface,
      ),
      titleMedium: body.titleMedium!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: onSurface,
      ),
      titleSmall: body.titleSmall!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: onSurface,
      ),
      bodyLarge: body.bodyLarge!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: onSurface,
      ),
      bodyMedium: body.bodyMedium!.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: muted,
      ),
      bodySmall: body.bodySmall!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: muted,
      ),
      labelLarge: body.labelLarge!.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      labelMedium: body.labelMedium!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
        color: muted,
      ),
      labelSmall: body.labelSmall!.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.4,
        color: muted,
      ),
    );
  }

  static ThemeData light() => _build(_light, BrandColors.light);
  static ThemeData dark() => _build(_dark, BrandColors.dark);

  static ThemeData _build(ColorScheme scheme, BrandColors brand) {
    final text = _typography(scheme.onSurface, scheme.onSurfaceVariant);
    final isLight = scheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      extensions: [brand],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _SharedAxisTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: _SharedAxisTransitionBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: _SharedAxisTransitionBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: scheme.surface,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: scheme.surface,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: Radii.md),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: const Size(64, kMinTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: Radii.sm),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(64, kMinTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
          textStyle: text.labelLarge,
          side: BorderSide(color: scheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: Radii.sm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, kMinTouchTarget),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: Radii.xs),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.square(kMinTouchTarget),
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface, size: IconSize.md),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Gap.md,
          vertical: Gap.md,
        ),
        hintStyle: text.bodyLarge!.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: text.bodyLarge!.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: text.titleSmall!.copyWith(color: scheme.primary),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(
          color: scheme.error,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: Radii.sm,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.sm,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.sm,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.sm,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Radii.sm,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        labelStyle: text.labelMedium!.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: text.labelMedium!.copyWith(color: scheme.onPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.sm,
          vertical: Gap.xs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.pill),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyLarge!.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        insetPadding: const EdgeInsets.all(Gap.md),
        shape: const RoundedRectangleBorder(borderRadius: Radii.sm),
        elevation: 6,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: brand.scrim,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyLarge!.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.lg),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: scheme.surfaceContainerHigh,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHigh,
        thumbColor: scheme.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.surfaceContainerLowest,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: Radii.xs,
        ),
        textStyle: text.bodySmall!.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}

class _SharedAxisTransitionBuilder extends PageTransitionsBuilder {
  const _SharedAxisTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (Motion.reduced(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    final enter = CurvedAnimation(parent: animation, curve: Motion.emphasized);
    final leave = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Motion.emphasized,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: const Interval(0.1, 1)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.045),
          end: Offset.zero,
        ).animate(enter),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -0.02),
          ).animate(leave),
          child: child,
        ),
      ),
    );
  }
}
