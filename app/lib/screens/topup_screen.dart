// lib/screens/topup_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';
import '../utils/format.dart';

class TopUpScreen extends StatefulWidget {
  final void Function(num amount, String method) onConfirm;
  const TopUpScreen({super.key, required this.onConfirm});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amount = TextEditingController(text: '5000');
  String _method = 'card';
  static const _suggestions = [1000, 2500, 5000, 10000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Carregar saldo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(children: [
            Text('MONTANTE', style: PagaliText.label),
            const SizedBox(height: 8),
            PField(controller: _amount, keyboardType: TextInputType.number, prefix: const Padding(padding: EdgeInsets.only(left: 4, right: 8), child: Text('CVE', style: TextStyle(fontFamily: PagaliText.family, color: PagaliColors.fgLight, fontWeight: FontWeight.w500)))),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final v in _suggestions) ChoiceChip(
                label: Text('${Money.cve(v)} CVE'),
                selected: false,
                onSelected: (_) => setState(() => _amount.text = v.toString()),
                labelStyle: const TextStyle(fontFamily: PagaliText.family, color: PagaliColors.purple, fontWeight: FontWeight.w500),
                backgroundColor: PagaliColors.purple50,
                side: BorderSide.none,
                shape: const StadiumBorder(),
              ),
            ]),
            const SizedBox(height: 20),
            Text('MÉTODO', style: PagaliText.label),
            const SizedBox(height: 8),
            PCard(padding: EdgeInsets.zero, child: Column(children: [
              _methodTile('card', Icons.credit_card, 'Cartão', '•••• 8821 · BCV'),
              const Divider(height: 1, color: Color(0x10000000)),
              _methodTile('bank', Icons.account_balance, 'Transferência bancária', 'BCV / Caixa'),
              const Divider(height: 1, color: Color(0x10000000)),
              _methodTile('agent', Icons.storefront, 'Agente Pagali', 'Loja parceira'),
            ])),
            const SizedBox(height: 28),
            PButton(label: 'Confirmar', fullWidth: true, onPressed: () {
              final amt = num.tryParse(_amount.text) ?? 0;
              if (amt > 0) widget.onConfirm(amt, _method);
            }),
          ]),
        ),
      ),
    );
  }

  Widget _methodTile(String id, IconData icon, String title, String sub) {
    final on = _method == id;
    return InkWell(
      onTap: () => setState(() => _method = id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: on ? PagaliColors.purple50 : const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: on ? PagaliColors.purple : PagaliColors.fgMuted),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15)),
            Text(sub, style: PagaliText.caption),
          ])),
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: on ? PagaliColors.purple : PagaliColors.fgLight, width: 2),
              color: on ? PagaliColors.purple : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: on ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }
}
