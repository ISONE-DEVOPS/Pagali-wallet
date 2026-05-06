// lib/screens/success_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../utils/format.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> tx;
  final VoidCallback onDone;
  const SuccessScreen({super.key, required this.tx, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final amt = tx['amount'] as num;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(),
          Container(
            width: 96, height: 96,
            decoration: const BoxDecoration(color: Color(0xFFE0F8EF), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Color(0xFF0E8B66), size: 48),
          ),
          const SizedBox(height: 16),
          const Text('Pagamento concluído', style: PagaliText.h3),
          const SizedBox(height: 6),
          Text(
            '${Money.cve(amt)} CVE enviados a ${tx['name']}.',
            textAlign: TextAlign.center,
            style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight),
          ),
          const SizedBox(height: 6),
          Text(
            'ID: T-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: PagaliColors.fgLight),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: PButton(label: 'Partilhar', variant: PButtonVariant.tertiary, icon: Icons.share_outlined, onPressed: () {}, fullWidth: true)),
            const SizedBox(width: 10),
            Expanded(child: PButton(label: 'Recibo', variant: PButtonVariant.tertiary, icon: Icons.receipt_long_outlined, onPressed: () {}, fullWidth: true)),
          ]),
          const SizedBox(height: 12),
          PButton(label: 'Voltar ao início', fullWidth: true, onPressed: onDone),
        ]),
      )),
    );
  }
}
