import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'screens/home_carousel.dart';

void main() => runApp(const SaphireApp());

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
      title: 'Saphire — SAT Practice',
      scrollBehavior: const AppScrollBehavior(),
      theme: base.copyWith(
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 100,
          titleTextStyle: base.textTheme.titleMedium?.copyWith(
            color: brandRed,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: .1,
          ),
          iconTheme: const IconThemeData(color: brandRed),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brandRed,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const HomeCarousel(),
    );
  }
}

// custom scroll behavior so mouse / trackpad / touch all work
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
