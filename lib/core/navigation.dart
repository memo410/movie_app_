import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final ValueNotifier<int> shellTabIndex = ValueNotifier<int>(ShellTab.home);

abstract final class ShellTab {
  static const int home = 0;
  static const int menu = 1;
  static const int cart = 2;
  static const int orders = 3;
  static const int profile = 4;
}

void goToShellTab(int index) {
  appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  shellTabIndex.value = index;
}
