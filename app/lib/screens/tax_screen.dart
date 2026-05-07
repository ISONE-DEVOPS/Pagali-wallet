// lib/screens/tax_screen.dart — Pagamento de Impostos
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';
import '../services/api_client.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../services/wallet_service.dart';

class TaxScreen extends StatefulWidget {
  final ApiClient api;
  final void Function(Map<String, dynamic>) onSuccess;
  const TaxScreen({super.key, required this.api, required this.onSuccess});
  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  List<Map<String, dynamic>> _types = [];
  Map<String, dynamic>? _selected;
  Map<String, dynamic>? _calc;
  Map<String, dynamic>? _receipt;
  final _nif    = TextEditingController(text: 'CV2389001A');
  final _amount = TextEditingController(text: '50000');
  final _period = TextEditingController(text: 'Maio 2026');
  bool _loading = false;
  bool _paying  = false;

  @override
  void initState() { super.initState(); _loadTypes(); }

  Future<void> _loadTypes() async {
    try {
      final data = await widget.api.getTaxTypes();
      if (mounted) setState(() => _types = data);
    } catch (_) {}
  }

  String? _validationError;

  Future<void> _calculate() async {
    if (_selected == null) { setState(() => _validationError = 'Seleccione o tipo de imposto'); return; }
    final nifErr    = Validators.nif(_nif.text);
    final amtErr    = Validators.amount(_amount.text, min: 1);
    final periodErr = Validators.period(_period.text);
    final err = nifErr ?? amtErr ?? periodErr;
    if (err != null) { setState(() => _validationError = err); return; }
    setState(() { _validationError = null; _loading = true; _calc = null; });
    try {
      final result = await widget.api.calculateTax(code: _selected!['code'], baseAmount: double.parse(_amount.text));
      if (mounted) setState(() { _calc = result; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _pay() async {
    if (_calc == null) return;
    final total = _calc!['total'] as num;
    if (!WalletService.instance.canDebit(total, 0)) {
      setState(() => _calc = {..._calc!, '_error': 'Saldo insuficiente (${Money.cve(WalletService.instance.balance.value)} CVE disponível)'}); return;
    }
    setState(() { _paying = true; });
    try {
      final result = await widget.api.payTax(
        nif: _nif.text, code: _selected!['code'],
        baseAmount: double.parse(_amount.text),
        payerMsisdn: '2389001', period: _period.text,
      );
      WalletService.instance.debit(result['total'] as num, 0);
      if (mounted) setState(() { _receipt = result; _paying = false; });
    } catch (_) { if (mounted) setState(() => _paying = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Pagamento de Impostos')),
      body: _receipt != null ? _receiptView() : _formView(),
    );
  }

  Widget _formView() {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Tipos de imposto
      const Text('TIPO DE IMPOSTO', style: PagaliText.label),
      const SizedBox(height: 10),
      ..._types.map((t) => GestureDetector(
        onTap: () { setState(() { _selected = t; _calc = null; }); },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _selected?['code'] == t['code'] ? PagaliColors.purple : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _selected?['code'] == t['code'] ? PagaliColors.purple : const Color(0x15000000)),
          ),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(
                color: _selected?['code'] == t['code'] ? Colors.white.withValues(alpha: .2) : PagaliColors.purple50,
                borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(t['code'], style: TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700, fontSize: 11,
                color: _selected?['code'] == t['code'] ? Colors.white : PagaliColors.purple))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t['name'], style: PagaliText.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: _selected?['code'] == t['code'] ? Colors.white : PagaliColors.fgDefault)),
              Text(t['description'], style: PagaliText.caption.copyWith(
                color: _selected?['code'] == t['code'] ? Colors.white70 : PagaliColors.fgLight)),
            ])),
            Text('${((t['rate'] as num) * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700,
                color: _selected?['code'] == t['code'] ? PagaliColors.lime : PagaliColors.fgMuted)),
          ]),
        ),
      )),

      const SizedBox(height: 20),
      PField(label: 'NIF', controller: _nif),
      const SizedBox(height: 12),
      PField(label: 'Valor Base (CVE)', controller: _amount, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      PField(label: 'Período', controller: _period),
      const SizedBox(height: 20),

      if (_validationError != null) ...[
        const SizedBox(height: 4),
        Text(_validationError!, style: const TextStyle(color: PagaliColors.danger, fontSize: 12)),
        const SizedBox(height: 8),
      ],
      _loading
        ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
        : PButton(label: 'Calcular Imposto', fullWidth: true, variant: PButtonVariant.tertiary,
            icon: Icons.calculate_outlined,
            onPressed: _selected == null ? null : _calculate),

      if (_calc != null) ...[
        const SizedBox(height: 16),
        PCard(child: Column(children: [
          _row('Valor base', '${Money.cve(_calc!['baseAmount'] as num)} CVE'),
          _row('Taxa (${((_selected!['rate'] as num)*100).toStringAsFixed(1)}%)',
            '${Money.cve(_calc!['taxAmount'] as num)} CVE'),
          const Divider(height: 16, color: Color(0x10000000)),
          _row('Total a pagar', '${Money.cve(_calc!['total'] as num)} CVE', emphasis: true),
        ])),
        const SizedBox(height: 16),
        _paying
          ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
          : PButton(label: 'Pagar ${Money.cve(_calc!['total'] as num)} CVE', fullWidth: true,
              icon: Icons.receipt_long_outlined, onPressed: _pay),
      ],
    ]);
  }

  Widget _receiptView() {
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 20),
      Center(child: Container(
        width: 80, height: 80,
        decoration: const BoxDecoration(color: Color(0xFFE0F8EF), shape: BoxShape.circle),
        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0E8B66), size: 44),
      )),
      const SizedBox(height: 20),
      const Center(child: Text('Pagamento efectuado', style: PagaliText.h3)),
      const SizedBox(height: 4),
      Center(child: Text('Imposto ${_receipt!['code']} liquidado com sucesso',
        style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight), textAlign: TextAlign.center)),
      const SizedBox(height: 24),
      PCard(child: Column(children: [
        _row('NIF', _receipt!['nif']),
        _row('Imposto', _receipt!['taxType']),
        _row('Período', _receipt!['period'] ?? '—'),
        _row('Montante', '${Money.cve(_receipt!['total'] as num)} CVE', emphasis: true),
        const Divider(height: 16, color: Color(0x10000000)),
        _row('Recibo', (_receipt!['receiptId'] as String).substring(0, 12).toUpperCase()),
        _row('Data', _receipt!['paidAt']?.toString().substring(0, 10) ?? ''),
      ])),
      const SizedBox(height: 24),
      PButton(label: 'Concluir', fullWidth: true, onPressed: () => setState(() { _receipt = null; _calc = null; })),
    ]);
  }

  Widget _row(String l, String r, {bool emphasis = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight, fontSize: 13)),
      Text(r, style: PagaliText.bodySm.copyWith(
        fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
        color: emphasis ? PagaliColors.purple : PagaliColors.fgDefault)),
    ]),
  );
}
