// lib/widgets/p_field.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class PField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  const PField({
    super.key,
    this.label,
    this.controller,
    this.placeholder,
    this.keyboardType,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label!, style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w500)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: PagaliText.body,
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: prefix == null ? null : Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: prefix,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            hintStyle: PagaliText.body.copyWith(color: PagaliColors.fgLight),
          ),
        ),
      ],
    );
  }
}
