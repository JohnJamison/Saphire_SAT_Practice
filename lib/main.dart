// Root app with bottom nav + new dashboard home.
// Safe to replace your current main.dart.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'screens/home_root.dart';
import 'screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';


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
      home: StreamBuilder<User?>(
        stream: AuthService.authStateChanges,  // Requires the stream getter from previous response
        builder: (context, snapshot) {
          // Loading while Firebase initializes
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Already signed in → HomeRoot (your bottom nav)
          if (snapshot.hasData) {
            return const HomeRoot();
          }
          
          // Not signed in → LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}