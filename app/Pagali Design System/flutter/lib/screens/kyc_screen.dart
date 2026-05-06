// lib/screens/kyc_screen.dart  —  Bilhete de Identidade Cabo-Verdiano (CIN) capture
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';

class KycScreen extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  const KycScreen({super.key, required this.onSubmit});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  int _step = 0; // 0 personal, 1 doc, 2 selfie, 3 review
  final _name = TextEditingController();
  final _cin  = TextEditingController();
  final _birth = TextEditingController();
  bool _docFront = false, _docBack = false, _selfie = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(
        title: const Text('Verificar identidade'),
        leading: _step == 0
          ? const BackButton()
          : IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _step--)),
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _stepper(),
          const SizedBox(height: 20),
          Expanded(child: _body()),
          PButton(
            label: _step == 3 ? 'Submeter' : 'Continuar',
            fullWidth: true,
            onPressed: () {
              if (_step < 3) {
                setState(() => _step++);
              } else {
                widget.onSubmit({
                  'name': _name.text, 'cin': _cin.text, 'dob': _birth.text,
                });
              }
            },
          ),
        ]),
      )),
    );
  }

  Widget _stepper() {
    return Row(children: [
      for (int i = 0; i < 4; i++) ...[
        Expanded(child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: i <= _step ? PagaliColors.purple : const Color(0x18000000),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        if (i < 3) const SizedBox(width: 6),
      ],
    ]);
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return ListView(children: [
          Text('Dados pessoais', style: PagaliText.h3),
          const SizedBox(height: 4),
          Text('Use o nome exacto que consta no seu BI.', style: PagaliText.bodySm),
          const SizedBox(height: 16),
          PField(label: 'Nome completo', controller: _name),
          const SizedBox(height: 12),
          PField(label: 'Nº de Bilhete (CIN)', controller: _cin, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          PField(label: 'Data de nascimento', controller: _birth, placeholder: 'DD/MM/AAAA'),
        ]);
      case 1:
        return ListView(children: [
          Text('Bilhete de Identidade', style: PagaliText.h3),
          const SizedBox(height: 4),
          Text('Tire foto da frente e do verso do seu BI.', style: PagaliText.bodySm),
          const SizedBox(height: 16),
          _docTile('Frente do BI', _docFront, () => setState(() => _docFront = true)),
          const SizedBox(height: 10),
          _docTile('Verso do BI', _docBack, () => setState(() => _docBack = true)),
        ]);
      case 2:
        return ListView(children: [
          Text('Selfie de verificação', style: PagaliText.h3),
          const SizedBox(height: 4),
          Text('Olhe para a câmara e siga as instruções.', style: PagaliText.bodySm),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _selfie = true),
            child: PCard(child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: _selfie ? PagaliColors.purple50 : const Color(0xFFF3F3F3),
                  shape: BoxShape.circle,
                ),
                child: Icon(_selfie ? Icons.check : Icons.face_outlined, size: 96, color: _selfie ? PagaliColors.purple : PagaliColors.fgLight),
              ),
            )),
          ),
        ]);
      default:
        return ListView(children: [
          Text('Confirme os seus dados', style: PagaliText.h3),
          const SizedBox(height: 16),
          PCard(child: Column(children: [
            _row('Nome', _name.text.isEmpty ? '—' : _name.text),
            _row('BI / CIN', _cin.text.isEmpty ? '—' : _cin.text),
            _row('Nascimento', _birth.text.isEmpty ? '—' : _birth.text),
            _row('Documento', _docFront && _docBack ? 'Frente + verso' : 'Em falta'),
            _row('Selfie', _selfie ? 'OK' : 'Em falta'),
          ])),
        ]);
    }
  }

  Widget _docTile(String label, bool done, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: PCard(child: Row(children: [
        Container(
          width: 56, height: 40,
          decoration: BoxDecoration(
            color: done ? PagaliColors.purple50 : const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Icon(done ? Icons.check : Icons.add_a_photo_outlined, color: done ? PagaliColors.purple : PagaliColors.fgLight, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15))),
        Text(done ? 'Recapturar' : 'Capturar', style: PagaliText.bodySm.copyWith(color: PagaliColors.purple, fontWeight: FontWeight.w500)),
      ])),
    );
  }

  Widget _row(String l, String r) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight, fontSize: 14)),
      Text(r, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500)),
    ]),
  );
}
