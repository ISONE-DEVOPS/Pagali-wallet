// lib/widgets/p_avatar.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class PAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color background;
  final Color foreground;

  const PAvatar({
    super.key,
    required this.name,
    this.size = 42,
    this.background = PagaliColors.purple50,
    this.foreground = PagaliColors.purple,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(_initials, style: TextStyle(
        fontFamily: PagaliText.family, color: foreground,
        fontSize: size * 0.4, fontWeight: FontWeight.w700,
      )),
    );
  }
}
