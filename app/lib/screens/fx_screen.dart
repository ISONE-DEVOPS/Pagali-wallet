// lib/screens/fx_screen.dart — FX: Remessa Internacional
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';
import '../services/api_client.dart';
import '../utils/format.dart';

class FxScreen extends StatefulWidget {
  final ApiClient api;
  final void Function(Map<String, dynamic>) onSuccess;
  const FxScreen({super.key, required this.api, required this.onSuccess});
  @override
  State<FxScreen> createState() => _FxScreenState();
}

class _FxScreenState extends State<FxScreen> {
  static const _currencies = ['EUR', 'USD', 'GBP', 'BRL'];
  static const _flags = {'EUR': '🇪🇺', 'USD': '🇺🇸', 'GBP': '🇬🇧', 'BRL': '🇧🇷'};
  static const _beneficiaries = [
    {'name': 'Ana Silva',     'msisdn': '2389001'},
    {'name': 'João Monteiro', 'msisdn': '2389002'},
    {'name': 'Maria Tavares', 'msisdn': '2389003'},
    {'name': 'Carlos Évora',  'msisdn': '2389004'},
  ];

  String _currency = 'EUR';
  Map<String, String> _selected = {'name': 'Ana Silva', 'msisdn': '2389001'};
  final _amountCtrl = TextEditingController(text: '100');
  Map<String, dynamic>? _quote;
  bool _loadingQuote = false;
  bool _paying = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(_onAmountChanged);
    _fetchQuote();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _fetchQuote);
  }

  Future<void> _fetchQuote() async {
    final amt = double.tryParse(_amountCtrl.text);
    if (amt == null || amt <= 0) return;
    setState(() { _loadingQuote = true; _quote = null; _error = null; });
    try {
      final q = await widget.api.getFxQuote(
        sourceCurrency: _currency,
        sourceAmount: amt,
        payeeMsisdn: _selected['msisdn']!,
      );
      if (mounted) setState(() { _quote = q; _loadingQuote = false; });
    } catch (_) {
      if (mounted) setState(() { _loadingQuote = false; _error = 'Erro ao obter taxa'; });
    }
  }

  Future<void> _pay() async {
    if (_quote == null) return;
    setState(() { _paying = true; _error = null; });
    try {
      final result = await widget.api.executeFxTransfer(
        sourceCurrency: _currency,
        sourceAmount: double.parse(_amountCtrl.text),
        targetAmount: (_quote!['targetAmount'] as num).toDouble(),
        exchangeRate: (_quote!['exchangeRate'] as num).toDouble(),
        fee: (_quote!['fee'] as num).toDouble(),
        payeeMsisdn: _selected['msisdn']!,
      );
      if (mounted) widget.onSuccess({
        'name': _selected['name'],
        'phone': _selected['msisdn'],
        'amount': result['targetAmount'],
        'transferId': result['transferId'],
        'note': 'Remessa $_currency → CVE',
        'kind': 'fx',
      });
    } catch (_) {
      if (mounted) setState(() { _paying = false; _error = 'Falha na transferência'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Remessa Internacional')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Moeda de origem
        PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MOEDA DE ORIGEM', style: PagaliText.label),
          const SizedBox(height: 12),
          Row(children: _currencies.map((c) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () { setState(() { _currency = c; _quote = null; }); _fetchQuote(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _currency == c ? PagaliColors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _currency == c ? PagaliColors.purple : const Color(0x20000000)),
                ),
                child: Text(
                  '${_flags[c]} $c',
                  style: TextStyle(
                    fontFamily: PagaliText.family, fontWeight: FontWeight.w600, fontSize: 14,
                    color: _currency == c ? Colors.white : PagaliColors.fgDefault,
                  ),
                ),
              ),
            ),
          )).toList()),
        ])),

        const SizedBox(height: 16),

        // Montante
        PField(
          label: 'Montante ($_currency)',
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          prefix: Text(_flags[_currency]!, style: const TextStyle(fontSize: 18)),
        ),

        const SizedBox(height: 16),

        // Beneficiário
        PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('BENEFICIÁRIO EM CABO VERDE', style: PagaliText.label),
          const SizedBox(height: 8),
          ..._beneficiaries.map((b) {
            final isSelected = _selected['msisdn'] == b['msisdn'];
            return InkWell(
              onTap: () { setState(() => _selected = b); _fetchQuote(); },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? PagaliColors.purple : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? PagaliColors.purple : const Color(0x40000000),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                  ),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b['name']!, style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w500)),
                    Text('+238 ${b['msisdn']}', style: PagaliText.caption),
                  ]),
                ]),
              ),
            );
          }),
        ])),

        const SizedBox(height: 16),

        // Quote
        if (_loadingQuote)
          const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: PagaliColors.purple),
          ))
        else if (_quote != null) ...[
          PCard(child: Column(children: [
            _row('Taxa de câmbio', '1 $_currency = ${Money.cve(_quote!['exchangeRate'] as num)} CVE'),
            _row('Envia', '${_amountCtrl.text} $_currency'),
            _row('Taxa Pagali (1,5%)', '${Money.cve(_quote!['fee'] as num)} CVE'),
            const Divider(height: 20, color: Color(0x10000000)),
            _row('Beneficiário recebe', '${Money.cve(_quote!['targetAmount'] as num)} CVE', emphasis: true),
          ])),
          const SizedBox(height: 8),
          Center(child: Text(
            'Taxa válida por 60 segundos',
            style: PagaliText.caption.copyWith(color: PagaliColors.fgLight),
          )),
        ],

        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: PagaliColors.danger, fontSize: 13), textAlign: TextAlign.center),
        ],

        const SizedBox(height: 24),

        _paying
          ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
          : PButton(
              label: 'Enviar Remessa',
              fullWidth: true,
              icon: Icons.send_outlined,
              onPressed: _quote == null ? null : _pay,
            ),
      ]),
    );
  }

  Widget _row(String l, String r, {bool emphasis = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: PagaliText.bodySm.copyWith(color: emphasis ? PagaliColors.fgDefault : PagaliColors.fgLight, fontSize: 13)),
      Text(r, style: emphasis
        ? const TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700, color: PagaliColors.purple, fontSize: 15)
        : PagaliText.bodySm.copyWith(fontWeight: FontWeight.w500)),
    ]),
  );
}
