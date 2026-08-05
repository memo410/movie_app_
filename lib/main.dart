import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/navigation.dart';
import 'core/theme.dart';
import 'data/menu_data.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const SavoraApp());
}

class SavoraApp extends StatefulWidget {
  const SavoraApp({super.key});

  @override
  State<SavoraApp> createState() => _SavoraAppState();
}

class _SavoraAppState extends State<SavoraApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) => MaterialApp(
          title: MenuData.restaurantName,
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          scaffoldMessengerKey: appMessengerKey,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _state.themeMode,
          home: const SplashScreen(),
          builder: (context, child) {
            final scale = MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.6,
            );
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: scale),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
