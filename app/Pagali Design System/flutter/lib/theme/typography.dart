// lib/theme/typography.dart
// Type scale — Roboto everywhere, mirrors colors_and_type.css.

import 'package:flutter/material.dart';
import 'colors.dart';

class PagaliText {
  static const String family = 'Roboto';

  static const TextStyle display = TextStyle(
    fontFamily: family, fontSize: 32, fontWeight: FontWeight.w700,
    height: 1.1, letterSpacing: -0.32, color: PagaliColors.fgDefault,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: family, fontSize: 28, fontWeight: FontWeight.w700,
    height: 1.2, color: PagaliColors.fgDefault,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: family, fontSize: 24, fontWeight: FontWeight.w400,
    height: 1.0, color: PagaliColors.fgDefault,
  ); // onboarding title
  static const TextStyle h3 = TextStyle(
    fontFamily: family, fontSize: 20, fontWeight: FontWeight.w500,
    height: 1.25, color: PagaliColors.fgDefault,
  );
  static const TextStyle body = TextStyle(
    fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400,
    height: 1.45, color: PagaliColors.fgDefault,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400,
    height: 1.45, color: PagaliColors.fgMuted,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.4, color: PagaliColors.fgLight, letterSpacing: 0.24,
  );
  static const TextStyle label = TextStyle(
    fontFamily: family, fontSize: 14, fontWeight: FontWeight.w500,
    height: 1.2, color: PagaliColors.fgMuted, letterSpacing: 0.84,
  );
  static const TextStyle amount = TextStyle(
    fontFamily: family, fontSize: 40, fontWeight: FontWeight.w700,
    height: 1.0, letterSpacing: -0.8, color: PagaliColors.fgDefault,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
