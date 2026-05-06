// lib/widgets/p_button.dart
// Pagali-branded button with 25px pill radius + press scale animation.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

enum PButtonVariant { primary, lime, white, ghost, tertiary, danger }

class PButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final PButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  const PButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
  });

  @override
  State<PButton> createState() => _PButtonState();
}

class _PButtonState extends State<PButton> {
  bool _pressed = false;

  ({Color bg, Color fg, BoxBorder? border, List<BoxShadow>? shadow}) _styleFor(PButtonVariant v) {
    switch (v) {
      case PButtonVariant.primary:
        return (
          bg: PagaliColors.purple, fg: Colors.white, border: null,
          shadow: [BoxShadow(color: PagaliColors.purple.withOpacity(.32), blurRadius: 18, offset: const Offset(0, 8))],
        );
      case PButtonVariant.lime:
        return (bg: PagaliColors.lime, fg: const Color(0xFF1A1A1A), border: null, shadow: null);
      case PButtonVariant.white:
        return (bg: Colors.white, fg: PagaliColors.purple, border: null, shadow: null);
      case PButtonVariant.ghost:
        return (
          bg: Colors.transparent, fg: Colors.white,
          border: Border.all(color: Colors.white.withOpacity(.6), width: 2), shadow: null,
        );
      case PButtonVariant.tertiary:
        return (bg: PagaliColors.purple50, fg: PagaliColors.purple, border: null, shadow: null);
      case PButtonVariant.danger:
        return (bg: PagaliColors.danger, fg: Colors.white, border: null, shadow: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _styleFor(widget.variant);
    final disabled = widget.onPressed == null;

    final child = AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: disabled ? 0.45 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.variant == PButtonVariant.ghost ? 26 : 28,
            vertical: widget.variant == PButtonVariant.ghost ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: s.bg, border: s.border, boxShadow: s.shadow,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: s.fg),
                const SizedBox(width: 8),
              ],
              Text(widget.label, style: TextStyle(
                fontFamily: PagaliText.family, fontSize: 16, fontWeight: FontWeight.w500, color: s.fg,
              )),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp:   disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: disabled ? null : widget.onPressed,
      child: widget.fullWidth ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
}
