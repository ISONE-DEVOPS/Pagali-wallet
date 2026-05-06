// lib/screens/g2p_screen.dart — G2P: Governo para Pessoa
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../services/api_client.dart';
import '../utils/format.dart';

class G2PScreen extends StatefulWidget {
  final ApiClient api;
  const G2PScreen({super.key, required this.api});
  @override
  State<G2PScreen> createState() => _G2PScreenState();
}

class _G2PScreenState extends State<G2PScreen> {
  static const _program = 'Subsídio Social — Maio 2026';
  static const _beneficiaries = [
    {'name': 'Ana Silva',      'msisdn': '2389001', 'amount': '5000'},
    {'name': 'João Monteiro',  'msisdn': '2389002', 'amount': '5000'},
    {'name': 'Maria Tavares',  'msisdn': '2389003', 'amount': '5000'},
    {'name': 'Carlos Évora',   'msisdn': '2389004', 'amount': '5000'},
  ];

  String? _batchId;
  Map<String, dynamic>? _batch;
  bool _loading = false;
  Timer? _poller;

  Future<void> _dispatch() async {
    setState(() { _loading = true; _batch = null; });
    try {
      final res = await widget.api.createG2PBatch(
        program: _program,
        beneficiaries: _beneficiaries,
      );
      setState(() { _batchId = res['batchId']; _loading = false; });
      _startPolling();
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_batchId == null) return;
      try {
        final batch = await widget.api.getG2PBatch(_batchId!);
        if (mounted) setState(() => _batch = batch);
        if (batch['state'] != 'PROCESSING') _poller?.cancel();
      } catch (_) {}
    });
  }

  @override
  void dispose() { _poller?.cancel(); super.dispose(); }

  Color _stateColor(String? s) {
    switch (s) {
      case 'SUCCESS':   return PagaliColors.success;
      case 'FAILED':    return PagaliColors.danger;
      case 'PENDING':   return PagaliColors.warning;
      default:          return PagaliColors.fgLight;
    }
  }

  String _stateLabel(String? s) {
    switch (s) {
      case 'SUCCESS': return 'Pago';
      case 'FAILED':  return 'Erro';
      case 'PENDING': return 'A processar…';
      default:        return s ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final batch = _batch;
    final summary = batch?['summary'] as Map? ?? {};
    final bens = (batch?['beneficiaries'] as List?)?.cast<Map>() ?? _beneficiaries;
    final isProcessing = batch?['state'] == 'PROCESSING';

    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('G2P — Subsídios Sociais')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PagaliColors.purple,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.account_balance, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text('Governo de Cabo Verde', style: PagaliText.caption.copyWith(color: Colors.white70)),
            ]),
            const SizedBox(height: 6),
            Text(_program, style: PagaliText.h3.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            Row(children: [
              _stat('Beneficiários', '${_beneficiaries.length}'),
              const SizedBox(width: 24),
              _stat('Total', '${Money.cve(20000)} CVE'),
              const SizedBox(width: 24),
              _stat('Por pessoa', '5.000 CVE'),
            ]),
          ]),
        ),

        const SizedBox(height: 16),

        // Sumário do batch
        if (batch != null) ...[
          PCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _pill('${summary['success'] ?? 0}', 'Pagos', PagaliColors.success),
            _pill('${summary['pending'] ?? 0}', 'Pendentes', PagaliColors.warning),
            _pill('${summary['failed'] ?? 0}', 'Erros', PagaliColors.danger),
          ])),
          const SizedBox(height: 16),
        ],

        // Lista de beneficiários
        PCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (int i = 0; i < bens.length; i++) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: PagaliColors.purple50,
                  child: Text(
                    (bens[i]['name'] as String)[0],
                    style: const TextStyle(color: PagaliColors.purple, fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(bens[i]['name'] as String, style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w500)),
                subtitle: Text('+238 ${bens[i]['msisdn']}', style: PagaliText.caption),
                trailing: batch == null
                  ? Text('5.000 CVE', style: PagaliText.bodySm.copyWith(color: PagaliColors.fgMuted))
                  : Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('5.000 CVE', style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w500)),
                      Text(
                        isProcessing && bens[i]['state'] == 'PENDING' ? 'A processar…' : _stateLabel(bens[i]['state'] as String?),
                        style: TextStyle(fontSize: 11, color: _stateColor(bens[i]['state'] as String?)),
                      ),
                    ]),
              ),
              if (i < bens.length - 1) const Divider(height: 1, color: Color(0x10000000)),
            ],
          ]),
        ),

        const SizedBox(height: 24),

        if (batch == null)
          _loading
            ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
            : PButton(
                label: 'Distribuir Subsídios',
                fullWidth: true,
                icon: Icons.send_outlined,
                onPressed: _dispatch,
              )
        else if (batch['state'] == 'PROCESSING')
          const Center(child: Column(children: [
            CircularProgressIndicator(color: PagaliColors.purple),
            SizedBox(height: 8),
            Text('A processar pagamentos…', style: PagaliText.caption),
          ]))
        else
          PCard(child: Column(children: [
            Icon(
              batch['state'] == 'COMPLETED' ? Icons.check_circle : Icons.warning_amber,
              color: batch['state'] == 'COMPLETED' ? PagaliColors.success : PagaliColors.warning,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              batch['state'] == 'COMPLETED' ? 'Distribuição concluída' : 'Concluído com erros',
              style: PagaliText.h3,
            ),
            const SizedBox(height: 4),
            Text('Batch ID: ${_batchId?.substring(0, 8).toUpperCase()}', style: PagaliText.caption),
          ])),
      ]),
    );
  }

  Widget _stat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: PagaliText.caption.copyWith(color: Colors.white60, fontSize: 11)),
    Text(value, style: PagaliText.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
  ]);

  Widget _pill(String count, String label, Color color) => Column(children: [
    Text(count, style: TextStyle(fontFamily: PagaliText.family, fontSize: 22, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: PagaliText.caption),
  ]);
}
