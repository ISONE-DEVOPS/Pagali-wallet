// lib/theme/colors.dart
// Pagali brand colors — extracted from pagali-app source + design system.

import 'package:flutter/material.dart';

class PagaliColors {
  // ── Brand ─────────────────────────────────────────────
  static const Color purple    = Color(0xFF6233A0); // mainColor
  static const Color purple700 = Color(0xFF4F2A82);
  static const Color purple300 = Color(0xFF8E6BBF);
  static const Color purple50  = Color(0xFFF1ECF8);

  static const Color lime      = Color(0xFFB4BF09); // buttomOnborardColor
  static const Color lime700   = Color(0xFF909808);
  static const Color lime300   = Color(0xFFD2DA4D);

  static const Color pink      = Color(0xFFFFABAB); // subscribeColor
  static const Color linkBlue  = Color(0xFF0169A6);

  // ── Neutrals ──────────────────────────────────────────
  static const Color bgApp        = Color(0xFFE5E5E5); // scaffoldBackgroundColor
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceDark  = Color(0xFF212020); // textBackgroundColor
  static const Color bottomNav    = Color(0xFF424242); // grey.shade800

  static const Color fgStrong  = Color(0xFF000000);
  static const Color fgDefault = Color(0xFF212020);
  static const Color fgMuted   = Color(0xFF515565); // unselectedLabelColor
  static const Color fgSubtle  = Color(0xFF666666); // darkTextColor
  static const Color fgLight   = Color(0xFF858585); // lightTextColor

  // ── Semantic ──────────────────────────────────────────
  static const Color success = Color(0xFF2BD9A8);
  static const Color warning = Color(0xFFFFC857);
  static const Color danger  = Color(0xFFE5484D);
  static const Color info    = linkBlue;

  // Dot inactive on purple bg
  static Color dotInactive = Colors.black.withOpacity(0.26);
}
