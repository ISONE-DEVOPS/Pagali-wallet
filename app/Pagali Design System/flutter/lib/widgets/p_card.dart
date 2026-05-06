// lib/widgets/p_card.dart
import 'package:flutter/material.dart';

class PCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const PCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFF281450).withOpacity(.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
