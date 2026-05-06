// lib/screens/request_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';

class RequestScreen extends StatefulWidget {
  final String myMsisdn;
  const RequestScreen({super.key, required this.myMsisdn});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _amount = TextEditingController(text: '1500');
  final _note = TextEditingController(text: 'Almoço de sábado');

  @override
  Widget build(BuildContext context) {
    final link = 'pagali://request?to=${widget.myMsisdn}&amount=${_amount.text}&note=${Uri.encodeQueryComponent(_note.text)}';
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Pedir dinheiro')),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(children: [
          PField(label: 'Montante (CVE)', controller: _amount, keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          PField(label: 'Motivo', controller: _note, onChanged: (_) => setState(() {})),
          const SizedBox(height: 20),
          Text('PARTILHAR', style: PagaliText.label),
          const SizedBox(height: 8),
          PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // QR placeholder (use qr_flutter when available)
            Center(child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(color: PagaliColors.purple50, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const Icon(Icons.qr_code_2, size: 140, color: PagaliColors.purple),
            )),
            const SizedBox(height: 14),
            Text('LINK', style: PagaliText.label),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF6F4F8), borderRadius: BorderRadius.circular(10)),
              child: Text(link, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: PagaliColors.fgDefault)),
            ),
          ])),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: PButton(label: 'Copiar link', icon: Icons.link, variant: PButtonVariant.tertiary, fullWidth: true, onPressed: () {})),
            const SizedBox(width: 10),
            Expanded(child: PButton(label: 'Partilhar', icon: Icons.share_outlined, fullWidth: true, onPressed: () {})),
          ]),
        ]),
      )),
    );
  }
}
