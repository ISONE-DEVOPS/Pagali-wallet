// lib/theme/theme.dart
// Top-level ThemeData for Pagali wallet.

import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

ThemeData buildPagaliTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: PagaliText.family,
    scaffoldBackgroundColor: PagaliColors.bgApp,
    colorScheme: const ColorScheme.light(
      primary:   PagaliColors.purple,
      secondary: PagaliColors.lime,
      surface:   PagaliColors.surface,
      error:     PagaliColors.danger,
      onPrimary: Colors.white,
      onSecondary: Color(0xFF1A1A1A),
      onSurface: PagaliColors.fgDefault,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: PagaliColors.fgDefault),
      titleTextStyle: TextStyle(
        fontFamily: PagaliText.family, fontSize: 17, fontWeight: FontWeight.w500,
        color: PagaliColors.fgDefault,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PagaliColors.purple,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: PagaliText.family, fontSize: 16, fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x18000000), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x18000000), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PagaliColors.purple, width: 1.5),
      ),
      labelStyle: PagaliText.bodySm,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
    ),
  );
}
