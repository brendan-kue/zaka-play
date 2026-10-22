import 'package:flutter/material.dart';

class Z {
  static const violet = Color(0xFF24124F);
  static const violet2 = Color(0xFF3A1F7A);
  static const mint = Color(0xFF1EE3A2);
  static const mintDark = Color(0xFF0E9C6B);
  static const gold = Color(0xFFFFC83D);
  static const ink = Color(0xFF1B1530);
  static const muted = Color(0xFF615980);
  static const bg = Color(0xFFF4F2FA);
  static const lilac = Color(0xFFE6E0FA);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Z.violet, primary: Z.violet, secondary: Z.mint),
    scaffoldBackgroundColor: Z.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: Z.ink, displayColor: Z.ink),
    appBarTheme: const AppBarTheme(backgroundColor: Z.bg, foregroundColor: Z.ink, elevation: 0, centerTitle: false),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
