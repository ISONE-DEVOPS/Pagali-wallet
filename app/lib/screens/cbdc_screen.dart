// lib/screens/cbdc_screen.dart — Escudo Digital (CBDC)
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';
import '../services/api_client.dart';
import '../utils/format.dart';

class CbdcScreen extends StatefulWidget {
  final ApiClient api;
  const CbdcScreen({super.key, required this.api});
  @override
  State<CbdcScreen> createState() => _CbdcScreenState();
}

class _CbdcScreenState extends State<CbdcScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Map<String, dynamic>? _wallet;
  Map<String, dynamic>? _supply;
  bool _loading = true;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); _load(); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        widget.api.getCbdcWallet('2389001'),
        widget.api.getCbdcSupply(),
      ]);
      if (mounted) setState(() { _wallet = results[0]; _supply = results[1]; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(
        title: const Text('Escudo Digital'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: PagaliColors.lime,
          labelColor: PagaliColors.purple,
          unselectedLabelColor: PagaliColors.fgLight,
          tabs: const [Tab(text: 'Carteira'), Tab(text: 'Converter'), Tab(text: 'BCV Mint')],
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
        : TabBarView(controller: _tabs, children: [
            _WalletTab(wallet: _wallet, supply: _supply),
            _ConvertTab(api: widget.api, onDone: _load),
            _MintTab(api: widget.api, onDone: _load),
          ]),
    );
  }
}

// ── Carteira ─────────────────────────────────────────────────────────────────
class _WalletTab extends StatelessWidget {
  final Map<String, dynamic>? wallet;
  final Map<String, dynamic>? supply;
  const _WalletTab({this.wallet, this.supply});

  @override
  Widget build(BuildContext context) {
    final balance = (wallet?['balance'] as num?) ?? 0;
    final totalSupply = (supply?['totalSupply'] as num?) ?? 0;

    return ListView(padding: const EdgeInsets.all(20), children: [
      // Carteira CBDC
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1a0a2e), Color(0xFF2d1057)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BANCO DE CABO VERDE', style: TextStyle(fontFamily: PagaliText.family, color: Colors.white38, fontSize: 10, letterSpacing: .1)),
              SizedBox(height: 2),
              Text('Escudo Digital', style: TextStyle(fontFamily: PagaliText.family, color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: PagaliColors.lime, borderRadius: BorderRadius.circular(999)),
              child: const Text('CBDC', style: TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF1A1A1A))),
            ),
          ]),
          const SizedBox(height: 24),
          const Text('SALDO', style: TextStyle(fontFamily: PagaliText.family, color: Colors.white38, fontSize: 11, letterSpacing: .08)),
          const SizedBox(height: 4),
          Text(
            '${Money.cve(balance)} ₠',
            style: const TextStyle(fontFamily: PagaliText.family, fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text('≡ ${Money.cve(balance)} CVE (paridade 1:1)', style: const TextStyle(fontFamily: PagaliText.family, color: Colors.white38, fontSize: 11)),
        ]),
      ),

      const SizedBox(height: 20),

      // Stats emissão
      PCard(child: Column(children: [
        const Align(alignment: Alignment.centerLeft, child: Text('EMISSÃO NACIONAL', style: PagaliText.label)),
        const SizedBox(height: 12),
        _stat('Circulação total', '${Money.cve(totalSupply)} ₠'),
        _stat('Emitido por', supply?['issuer'] ?? 'BCV'),
        _stat('Paridade', '1 ₠ = 1 CVE (fixo)'),
        _stat('Moeda base', 'Escudo Cabo-verdiano (CVE)'),
      ])),

      const SizedBox(height: 16),

      const PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SOBRE O ESCUDO DIGITAL', style: PagaliText.label),
        SizedBox(height: 10),
        Text(
          'O Escudo Digital é a versão digital do Escudo Cabo-verdiano emitida directamente pelo Banco de Cabo Verde. '
          'Tem paridade 1:1 com a moeda física e pode ser convertido em qualquer momento.',
          style: PagaliText.bodySm,
        ),
      ])),
    ]);
  }

  Widget _stat(String l, String r) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight, fontSize: 13)),
      Text(r, style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Converter ────────────────────────────────────────────────────────────────
class _ConvertTab extends StatefulWidget {
  final ApiClient api;
  final VoidCallback onDone;
  const _ConvertTab({required this.api, required this.onDone});
  @override State<_ConvertTab> createState() => _ConvertTabState();
}

class _ConvertTabState extends State<_ConvertTab> {
  final _amount = TextEditingController(text: '1000');
  bool _toCbdc = true;
  bool _loading = false;
  String? _message;

  Future<void> _convert() async {
    setState(() { _loading = true; _message = null; });
    try {
      final result = _toCbdc
        ? await widget.api.convertToCbdc(msisdn: '2389001', amount: double.parse(_amount.text))
        : await widget.api.convertToCve(msisdn: '2389001', amount: double.parse(_amount.text));
      if (mounted) {
        setState(() {
          _message = '${Money.cve(result['amount'] as num)} ${_toCbdc ? 'CVE → ₠ CBDC' : '₠ CBDC → CVE'} convertidos!';
          _loading = false;
        });
        widget.onDone();
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Toggle
      PCard(child: Row(children: [
        Expanded(child: GestureDetector(
          onTap: () => setState(() => _toCbdc = true),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: _toCbdc ? PagaliColors.purple : Colors.transparent, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text('CVE → ₠ CBDC', style: TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w600,
              color: _toCbdc ? Colors.white : PagaliColors.fgMuted)),
          ),
        )),
        Expanded(child: GestureDetector(
          onTap: () => setState(() => _toCbdc = false),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: !_toCbdc ? PagaliColors.purple : Colors.transparent, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text('₠ CBDC → CVE', style: TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w600,
              color: !_toCbdc ? Colors.white : PagaliColors.fgMuted)),
          ),
        )),
      ])),
      const SizedBox(height: 20),
      PField(label: _toCbdc ? 'Montante CVE' : 'Montante CBDC (₠)', controller: _amount, keyboardType: TextInputType.number),
      const SizedBox(height: 8),
      Text('Taxa de conversão: 1:1 (sem comissão)', style: PagaliText.caption.copyWith(color: PagaliColors.fgLight)),
      const SizedBox(height: 20),
      if (_message != null) ...[
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE0F8EF), borderRadius: BorderRadius.circular(10)),
          child: Text(_message!, style: const TextStyle(color: Color(0xFF0E8B66), fontWeight: FontWeight.w600))),
        const SizedBox(height: 12),
      ],
      _loading
        ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
        : PButton(label: _toCbdc ? 'Converter para Escudo Digital' : 'Converter para CVE', fullWidth: true, onPressed: _convert),
    ]);
  }
}

// ── BCV Mint ─────────────────────────────────────────────────────────────────
class _MintTab extends StatefulWidget {
  final ApiClient api;
  final VoidCallback onDone;
  const _MintTab({required this.api, required this.onDone});
  @override State<_MintTab> createState() => _MintTabState();
}

class _MintTabState extends State<_MintTab> {
  final _msisdn = TextEditingController(text: '2389001');
  final _amount = TextEditingController(text: '10000');
  bool _loading = false;
  String? _message;

  Future<void> _mint() async {
    setState(() { _loading = true; _message = null; });
    try {
      final result = await widget.api.cbdcMint(msisdn: _msisdn.text, amount: double.parse(_amount.text));
      if (mounted) {
        setState(() {
          _message = '${Money.cve(result['amount'] as num)} ₠ emitidos. Circulação total: ${Money.cve(result['totalSupply'] as num)} ₠';
          _loading = false;
        });
        widget.onDone();
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1a0a2e), borderRadius: BorderRadius.circular(14)),
        child: const Row(children: [
          Icon(Icons.account_balance, color: PagaliColors.lime, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Autorização BCV — Emissão de Escudo Digital.\nSó o Banco Central pode emitir CBDC.',
            style: TextStyle(fontFamily: PagaliText.family, color: Colors.white70, fontSize: 12, height: 1.4))),
        ]),
      ),
      const SizedBox(height: 20),
      PField(label: 'MSISDN Destinatário', controller: _msisdn, keyboardType: TextInputType.phone),
      const SizedBox(height: 12),
      PField(label: 'Montante a Emitir (₠)', controller: _amount, keyboardType: TextInputType.number),
      const SizedBox(height: 20),
      if (_message != null) ...[
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: PagaliColors.purple50, borderRadius: BorderRadius.circular(10)),
          child: Text(_message!, style: const TextStyle(color: PagaliColors.purple, fontWeight: FontWeight.w600, fontSize: 13))),
        const SizedBox(height: 12),
      ],
      _loading
        ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
        : PButton(label: 'Emitir Escudo Digital', fullWidth: true, icon: Icons.add_circle_outline, onPressed: _mint),
    ]);
  }
}
