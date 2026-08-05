import 'package:flutter/material.dart';

abstract final class Gap {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double section = 48;

  static const Widget h4 = SizedBox(height: xxs);
  static const Widget h8 = SizedBox(height: xs);
  static const Widget h12 = SizedBox(height: sm);
  static const Widget h16 = SizedBox(height: md);
  static const Widget h20 = SizedBox(height: lg);
  static const Widget h24 = SizedBox(height: xl);
  static const Widget h32 = SizedBox(height: xxl);
  static const Widget h40 = SizedBox(height: xxxl);

  static const Widget w4 = SizedBox(width: xxs);
  static const Widget w8 = SizedBox(width: xs);
  static const Widget w12 = SizedBox(width: sm);
  static const Widget w16 = SizedBox(width: md);
  static const Widget w24 = SizedBox(width: xl);
}

abstract final class Radii {
  static const BorderRadius xs = BorderRadius.all(Radius.circular(8));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(12));
  static const BorderRadius md = BorderRadius.all(Radius.circular(16));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(22));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(28));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 380);
  static const Duration page = Duration(milliseconds: 340);

  static const Duration exitFast = Duration(milliseconds: 110);
  static const Duration exitBase = Duration(milliseconds: 160);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve pop = Curves.easeOutBack;

  static const Duration stagger = Duration(milliseconds: 45);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

abstract final class IconSize {
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 26;
  static const double xl = 34;
}

abstract final class Shadows {
  static List<BoxShadow> card(Brightness brightness) =>
      brightness == Brightness.light
          ? const [
              BoxShadow(
                color: Color(0x0F1C1917),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ];

  static List<BoxShadow> raised(Brightness brightness) =>
      brightness == Brightness.light
          ? const [
              BoxShadow(
                color: Color(0x1A1C1917),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ];

  static List<BoxShadow> brand(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}

const double kMinTouchTarget = 48;

String money(double value) {
  final text = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return 'EGP $buffer';
}
