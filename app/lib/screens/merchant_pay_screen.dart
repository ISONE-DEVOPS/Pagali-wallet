// lib/screens/merchant_pay_screen.dart  (P2M confirm)
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';

class MerchantPayScreen extends StatefulWidget {
  final Map<String, dynamic> merchant;
  final void Function(Map<String, dynamic>) onPay;
  const MerchantPayScreen({super.key, required this.merchant, required this.onPay});

  @override
  State<MerchantPayScreen> createState() => _MerchantPayScreenState();
}

class _MerchantPayScreenState extends State<MerchantPayScreen> {
  late final TextEditingController _amount = TextEditingController(text: widget.merchant['amount']?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    final m = widget.merchant;
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Pagar comerciante')),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          PCard(child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: PagaliColors.lime, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Text(m['name'].toString()[0], style: const TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF1A1A1A))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m['name'], style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15)),
              Text('${m['city']} · MCC ${m['mcc']}', style: PagaliText.caption),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE0F8EF), borderRadius: BorderRadius.circular(999)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shield_outlined, size: 12, color: Color(0xFF0E8B66)),
                SizedBox(width: 4),
                Text('Verificado', style: TextStyle(fontFamily: PagaliText.family, fontSize: 11, color: Color(0xFF0E8B66), fontWeight: FontWeight.w500)),
              ]),
            ),
          ])),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: PagaliColors.purple, borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
            width: double.infinity,
            child: Column(children: [
              Text('MONTANTE', style: PagaliText.label.copyWith(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none, filled: false, contentPadding: EdgeInsets.zero),
                    style: const TextStyle(
                      fontFamily: PagaliText.family, fontSize: 48, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('CVE', style: PagaliText.bodySm.copyWith(color: Colors.white70, fontWeight: FontWeight.w500)),
              ]),
            ]),
          ),
          const Spacer(),
          PButton(
            label: 'Pagar agora', fullWidth: true,
            onPressed: () => widget.onPay({
              'name': m['name'], 'phone': m['city'],
              'amount': num.tryParse(_amount.text) ?? 0,
              'note': 'Pagali P2M payment', 'kind': 'p2m',
            }),
          ),
        ]),
      )),
    );
  }
}
