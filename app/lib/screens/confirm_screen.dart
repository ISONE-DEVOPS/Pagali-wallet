// lib/screens/confirm_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_avatar.dart';
import '../utils/format.dart';

class ConfirmScreen extends StatelessWidget {
  final Map<String, dynamic> tx;
  final VoidCallback onConfirm;
  const ConfirmScreen({super.key, required this.tx, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final amt = (tx['amount'] as num);
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Confirmar')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 12),
            PAvatar(name: tx['name'], size: 72),
            const SizedBox(height: 14),
            const Text('A enviar a', style: PagaliText.caption),
            const SizedBox(height: 4),
            Text(tx['name'], style: PagaliText.h3),
            Text(tx['phone'] ?? '', style: PagaliText.caption),
            const SizedBox(height: 20),
            PCard(child: Column(children: [
              _row('Montante', '${Money.cve(amt)} CVE'),
              _row('Taxa', '0,00 CVE'),
              const Divider(height: 16, color: Color(0x10000000)),
              _row('Total', '${Money.cve(amt)} CVE', emphasis: true),
              if ((tx['note'] as String?)?.isNotEmpty == true) ...[
                const Divider(height: 16, color: Color(0x10000000)),
                const Align(alignment: Alignment.centerLeft, child: Text('Nota', style: PagaliText.caption)),
                const SizedBox(height: 2),
                Align(alignment: Alignment.centerLeft, child: Text(tx['note'], style: PagaliText.bodySm)),
              ],
            ])),
            const Spacer(),
            PButton(label: 'Pagar agora', fullWidth: true, onPressed: onConfirm),
            const SizedBox(height: 12),
            PButton(label: 'Cancelar', fullWidth: true, variant: PButtonVariant.tertiary, onPressed: () => Navigator.of(context).pop()),
          ]),
        ),
      ),
    );
  }

  Widget _row(String l, String r, {bool emphasis = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: PagaliText.bodySm.copyWith(color: emphasis ? PagaliColors.fgDefault : PagaliColors.fgLight, fontSize: 14)),
        Text(r, style: emphasis
          ? const TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700, color: PagaliColors.purple, fontFeatures: [FontFeature.tabularFigures()])
          : PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }
}
