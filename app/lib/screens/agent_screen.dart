// lib/screens/agent_screen.dart — Agent Banking
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';
import '../services/api_client.dart';
import '../utils/format.dart';

class AgentScreen extends StatefulWidget {
  final ApiClient api;
  const AgentScreen({super.key, required this.api});
  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  List<Map<String, dynamic>> _agents = [];
  Map<String, dynamic>? _selected;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await widget.api.getAgents();
      if (mounted) setState(() { _agents = data; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _selectAgent(Map<String, dynamic> a) async {
    try {
      final detail = await widget.api.getAgent(a['agentId']);
      if (mounted) setState(() => _selected = detail);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) return _agentDetail(_selected!);
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Agent Banking')),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
        : ListView(padding: const EdgeInsets.all(20), children: [
            // Explicação
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: PagaliColors.purple, borderRadius: BorderRadius.circular(16)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.people_outline, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text('Rede de Agentes', style: TextStyle(fontFamily: PagaliText.family, color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                ]),
                SizedBox(height: 8),
                Text('Agentes humanos nas ilhas sem banco. Fazem cash-in e cash-out em nome do cliente.',
                  style: TextStyle(fontFamily: PagaliText.family, color: Colors.white70, fontSize: 13, height: 1.4)),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('AGENTES DISPONÍVEIS', style: PagaliText.label),
            const SizedBox(height: 10),
            for (final a in _agents) _agentCard(a),
          ]),
    );
  }

  Widget _agentCard(Map<String, dynamic> a) {
    return GestureDetector(
      onTap: () => _selectAgent(a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: PagaliColors.purple.withValues(alpha: .08), blurRadius: 8)]),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: PagaliColors.purple50, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: const Icon(Icons.store_outlined, color: PagaliColors.purple, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['name'], style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            Text('${a['island']} · ${a['location']}', style: PagaliText.caption),
            const SizedBox(height: 4),
            Text('Float: ${Money.cve(a['float'] as num)} CVE', style: PagaliText.caption.copyWith(color: PagaliColors.success, fontWeight: FontWeight.w600)),
          ])),
          const Icon(Icons.chevron_right, color: PagaliColors.fgLight),
        ]),
      ),
    );
  }

  Widget _agentDetail(Map<String, dynamic> a) {
    return _AgentDetailView(api: widget.api, agent: a, onBack: () => setState(() => _selected = null));
  }
}

class _AgentDetailView extends StatefulWidget {
  final ApiClient api;
  final Map<String, dynamic> agent;
  final VoidCallback onBack;
  const _AgentDetailView({required this.api, required this.agent, required this.onBack});
  @override State<_AgentDetailView> createState() => _AgentDetailViewState();
}

class _AgentDetailViewState extends State<_AgentDetailView> {
  final _msisdn = TextEditingController(text: '2389001');
  final _amount = TextEditingController(text: '5000');
  bool _loading = false;
  String? _message;
  List _txs = [];

  @override
  void initState() { super.initState(); _txs = widget.agent['transactions'] ?? []; }

  Future<void> _operate(String type) async {
    setState(() { _loading = true; _message = null; });
    try {
      final result = type == 'in'
        ? await widget.api.agentCashIn(widget.agent['agentId'], _msisdn.text, double.parse(_amount.text))
        : await widget.api.agentCashOut(widget.agent['agentId'], _msisdn.text, double.parse(_amount.text));
      if (mounted) {
        setState(() {
        _loading = false;
        _message = '${type == 'in' ? 'Cash-in' : 'Cash-out'} de ${Money.cve(result['amount'] as num)} CVE realizado!';
        _txs = [result, ..._txs];
      });
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: Text(widget.agent['name']), leading: BackButton(onPressed: widget.onBack)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Header agente
        PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.agent['name'], style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('${widget.agent['island']} · ${widget.agent['location']}', style: PagaliText.caption),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('FLOAT', style: PagaliText.label),
              Text('${Money.cve(widget.agent['float'] as num)} CVE',
                style: PagaliText.bodySm.copyWith(color: PagaliColors.success, fontWeight: FontWeight.w700, fontSize: 16)),
            ]),
          ]),
        ])),
        const SizedBox(height: 20),

        // Operação
        PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('OPERAÇÃO', style: PagaliText.label),
          const SizedBox(height: 12),
          PField(label: 'MSISDN do Cliente', controller: _msisdn, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          PField(label: 'Montante (CVE)', controller: _amount, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          if (_message != null) ...[
            Text(_message!, style: const TextStyle(color: PagaliColors.success, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
          ],
          _loading
            ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
            : Row(children: [
                Expanded(child: PButton(
                  label: '⬇ Cash-In', fullWidth: true, variant: PButtonVariant.ghost,
                  onPressed: () => _operate('in'),
                )),
                const SizedBox(width: 12),
                Expanded(child: PButton(
                  label: '⬆ Cash-Out', fullWidth: true,
                  onPressed: () => _operate('out'),
                )),
              ]),
        ])),
        const SizedBox(height: 20),

        // Histórico
        if (_txs.isNotEmpty) ...[
          const Text('OPERAÇÕES RECENTES', style: PagaliText.label),
          const SizedBox(height: 8),
          PCard(padding: EdgeInsets.zero, child: Column(children: [
            for (int i = 0; i < _txs.take(8).length; i++) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Icon(_txs[i]['type'] == 'CASH_IN' ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 16, color: _txs[i]['type'] == 'CASH_IN' ? PagaliColors.success : PagaliColors.purple),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_txs[i]['type'] == 'CASH_IN' ? 'Cash-In' : 'Cash-Out',
                        style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w500)),
                      Text(_txs[i]['customerMsisdn'], style: PagaliText.caption),
                    ]),
                  ]),
                  Text('${Money.cve(_txs[i]['amount'] as num)} CVE',
                    style: PagaliText.bodySm.copyWith(
                      color: _txs[i]['type'] == 'CASH_IN' ? PagaliColors.success : PagaliColors.fgDefault,
                      fontWeight: FontWeight.w700)),
                ]),
              ),
              if (i < _txs.take(8).length - 1) const Divider(height: 1, color: Color(0x10000000)),
            ],
          ])),
        ],
      ]),
    );
  }
}
