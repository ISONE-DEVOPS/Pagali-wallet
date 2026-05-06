// lib/screens/send_screen.dart  (P2P)
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';
import '../widgets/p_avatar.dart';
import '../utils/format.dart';

class SendScreen extends StatefulWidget {
  /// Returns the chosen {name, msisdn, amount, note} on completion.
  final void Function(Map<String, dynamic>) onContinue;
  const SendScreen({super.key, required this.onContinue});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  int _step = 0;
  final _phone = TextEditingController(text: '+238 ');
  final _amount = TextEditingController(text: '2500');
  final _note = TextEditingController();
  String _selectedName = 'João Monteiro';
  String _selectedMsisdn = '2389002';

  // Recentes — MSISDNs alinhados com o backend (core-connector/src/data/accounts.js)
  final _recents = const [
    {'name': 'João Monteiro', 'msisdn': '2389002', 'phone': '+238 938 9002'},
    {'name': 'Maria Tavares', 'msisdn': '2389003', 'phone': '+238 938 9003'},
    {'name': 'Carlos Évora',  'msisdn': '2389004', 'phone': '+238 938 9004'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(
        title: const Text('Enviar dinheiro'),
        backgroundColor: PagaliColors.bgApp,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: _step == 0 ? _stepRecipient() : _stepAmount(),
        ),
      ),
    );
  }

  Widget _stepRecipient() {
    return ListView(
      children: [
        PField(label: 'Para (número de telemóvel)', controller: _phone, keyboardType: TextInputType.phone, prefix: const Icon(Icons.phone_outlined, size: 16, color: PagaliColors.fgLight)),
        const SizedBox(height: 20),
        const Text('RECENTES', style: PagaliText.label),
        const SizedBox(height: 10),
        PCard(padding: EdgeInsets.zero, child: Column(
          children: [
            for (int i = 0; i < _recents.length; i++) ...[
              ListTile(
                leading: PAvatar(name: _recents[i]['name']!),
                title: Text(_recents[i]['name']!, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: Text(_recents[i]['phone']!, style: PagaliText.caption),
                trailing: const Icon(Icons.chevron_right, color: PagaliColors.fgLight),
                onTap: () {
                  setState(() {
                    _phone.text = _recents[i]['phone']!;
                    _selectedName = _recents[i]['name']!;
                    _selectedMsisdn = _recents[i]['msisdn']!;
                    _step = 1;
                  });
                },
              ),
              if (i < _recents.length - 1) const Divider(height: 1, color: Color(0x10000000)),
            ],
          ],
        )),
        const SizedBox(height: 24),
        PButton(label: 'Continuar', fullWidth: true, onPressed: () => setState(() => _step = 1)),
      ],
    );
  }

  Widget _stepAmount() {
    return ListView(children: [
      PCard(child: Row(children: [
        PAvatar(name: _selectedName),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_selectedName, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15)),
          Text('${_phone.text} · BCVCVCV', style: PagaliText.caption),
        ])),
      ])),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: PagaliColors.purple50, borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
        child: Column(children: [
          Text('MONTANTE', style: PagaliText.label.copyWith(color: PagaliColors.purple)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            SizedBox(
              width: 180,
              child: TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none, filled: false, contentPadding: EdgeInsets.zero),
                style: const TextStyle(
                  fontFamily: PagaliText.family, fontSize: 48, fontWeight: FontWeight.w700,
                  color: PagaliColors.purple, fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('CVE', style: PagaliText.bodySm.copyWith(color: PagaliColors.purple, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 6),
          Text('Disponível: ${Money.cve(5320)} CVE', style: PagaliText.caption.copyWith(color: PagaliColors.purple.withOpacity(.7))),
        ]),
      ),
      const SizedBox(height: 16),
      PField(label: 'Nota (opcional)', controller: _note, placeholder: 'Almoço, renda…'),
      const SizedBox(height: 24),
      PButton(
        label: 'Confirmar e enviar', fullWidth: true,
        onPressed: () => widget.onContinue({
          'name': _selectedName,
          'msisdn': _selectedMsisdn,
          'phone': _phone.text,
          'amount': num.tryParse(_amount.text) ?? 0,
          'note': _note.text,
          'kind': 'p2p',
        }),
      ),
    ]);
  }
}
