// Root app with bottom nav + new dashboard home.
// Safe to replace your current main.dart.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'screens/home_root.dart';
import 'package:firebase_core/firebase_core.dart';


// void main() => runApp(const SaphireApp());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SaphireApp());
}


// Allow scrolling with touch/mouse/trackpad on web/desktop.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class SaphireApp extends StatelessWidget {
  const SaphireApp({super.key});
  static const brandRed = Color(0xFFB80F0A);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: brandRed),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saphire SAT',
      scrollBehavior: const AppScrollBehavior(),
      theme: base.copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brandRed,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        ),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias),
      ),
      home: const HomeRoot(), // <- new bottom-nav shell
    );
  }
}
