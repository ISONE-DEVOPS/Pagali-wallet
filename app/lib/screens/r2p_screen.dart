// lib/screens/r2p_screen.dart — Request to Pay
// Duas vistas: COBRAR (comerciante envia pedido) e PEDIDOS (pagador vê e confirma)
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_field.dart';
import '../services/api_client.dart';
import '../utils/format.dart';
import '../services/wallet_service.dart';

class R2PScreen extends StatefulWidget {
  final ApiClient api;
  final void Function(Map<String, dynamic>) onSuccess;
  const R2PScreen({super.key, required this.api, required this.onSuccess});
  @override
  State<R2PScreen> createState() => _R2PScreenState();
}

class _R2PScreenState extends State<R2PScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(
        title: const Text('Request to Pay'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: PagaliColors.lime,
          labelColor: PagaliColors.purple,
          unselectedLabelColor: PagaliColors.fgLight,
          tabs: const [Tab(text: 'Cobrar (Comerciante)'), Tab(text: 'Pedidos (Pagador)')],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _MerchantSend(api: widget.api),
        _PayerInbox(api: widget.api, onSuccess: widget.onSuccess),
      ]),
    );
  }
}

// ── Comerciante envia pedido ────────────────────────────────────────────────
class _MerchantSend extends StatefulWidget {
  final ApiClient api;
  const _MerchantSend({required this.api});
  @override State<_MerchantSend> createState() => _MerchantSendState();
}

class _MerchantSendState extends State<_MerchantSend> {
  final _amount = TextEditingController(text: '850');
  final _desc   = TextEditingController(text: 'Refeição');
  final _payer  = TextEditingController(text: '2389001');
  bool _loading = false;
  Map<String, dynamic>? _sent;

  Future<void> _send() async {
    setState(() { _loading = true; _sent = null; });
    try {
      final r = await widget.api.createR2P(
        merchantId: 'MER001', merchantName: 'Restaurante Sodade',
        payerMsisdn: _payer.text.trim(), amount: double.parse(_amount.text),
        description: _desc.text,
      );
      if (mounted) setState(() { _sent = r; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('COMERCIANTE', style: PagaliText.label),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: PagaliColors.lime, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center,
            child: const Text('RS', style: TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A1A1A)))),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Restaurante Sodade', style: PagaliText.bodySm),
            Text('Mindelo · MCC 5812', style: PagaliText.caption),
          ]),
        ]),
      ])),
      const SizedBox(height: 16),
      PField(label: 'MSISDN do Pagador', controller: _payer, keyboardType: TextInputType.phone),
      const SizedBox(height: 12),
      PField(label: 'Montante (CVE)', controller: _amount, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      PField(label: 'Descrição', controller: _desc),
      const SizedBox(height: 24),
      _loading ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
        : PButton(label: 'Enviar Pedido de Pagamento', fullWidth: true, icon: Icons.send_outlined, onPressed: _send),

      if (_sent != null) ...[
        const SizedBox(height: 20),
        PCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.check_circle, color: PagaliColors.success, size: 18),
            SizedBox(width: 8),
            Text('Pedido enviado!', style: PagaliText.bodySm),
          ]),
          const SizedBox(height: 8),
          Text('ID: ${(_sent!['requestId'] as String).substring(0, 8).toUpperCase()}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: PagaliColors.fgLight)),
          Text('Expira: ${_sent!['expiresAt']}', style: PagaliText.caption),
          const SizedBox(height: 6),
          Text('O pagador ${_payer.text} recebe a notificação e confirma o pagamento.', style: PagaliText.caption),
        ])),
      ],
    ]);
  }
}

// ── Pagador vê pedidos pendentes ────────────────────────────────────────────
class _PayerInbox extends StatefulWidget {
  final ApiClient api;
  final void Function(Map<String, dynamic>) onSuccess;
  const _PayerInbox({required this.api, required this.onSuccess});
  @override State<_PayerInbox> createState() => _PayerInboxState();
}

class _PayerInboxState extends State<_PayerInbox> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() { super.initState(); _load(); _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load()); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _load() async {
    try {
      final data = await widget.api.getR2PForPayer('2389001');
      if (mounted) setState(() { _requests = data; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _accept(Map<String, dynamic> r) async {
    final amount = r['amount'] as num;
    if (!WalletService.instance.canDebit(amount, amount * 0.005)) {
      if (mounted) setState(() => _error = 'Saldo insuficiente (${(WalletService.instance.balance.value).toStringAsFixed(2)} CVE disponível)');
      return;
    }
    try {
      final result = await widget.api.acceptR2P(r['requestId']);
      WalletService.instance.debit(r['amount'] as num, result['fee'] ?? 0);
      if (mounted) {
        widget.onSuccess({
        'name': r['merchantName'] ?? 'Comerciante',
        'phone': r['merchantId'],
        'amount': r['amount'],
        'transferId': result['transferId'],
        'kind': 'r2p',
      });
      }
    } catch (_) {}
  }

  Future<void> _reject(Map<String, dynamic> r) async {
    await widget.api.rejectR2P(r['requestId']);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _requests.where((r) => r['state'] == 'PENDING').toList();
    final done    = _requests.where((r) => r['state'] != 'PENDING').toList();

    return _loading
      ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
      : ListView(padding: const EdgeInsets.all(20), children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFFFE4E4), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.error_outline, color: PagaliColors.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: PagaliColors.danger, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          if (pending.isEmpty) PCard(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Icon(Icons.inbox_outlined, size: 48, color: PagaliColors.fgLight),
              const SizedBox(height: 8),
              Text('Sem pedidos pendentes', style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight)),
              const Text('Vai ao separador "Cobrar" para simular um pedido', style: PagaliText.caption),
            ]),
          ))
          else ...[
            const Text('PEDIDOS PENDENTES', style: PagaliText.label),
            const SizedBox(height: 8),
            for (final r in pending) _pendingCard(r),
          ],
          if (done.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('HISTÓRICO', style: PagaliText.label),
            const SizedBox(height: 8),
            PCard(padding: EdgeInsets.zero, child: Column(children: done.take(5).map((r) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(r['merchantName'] ?? r['merchantId'], style: PagaliText.bodySm),
                Row(children: [
                  Text('${Money.cve(r['amount'] as num)} CVE', style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: r['state'] == 'ACCEPTED' ? const Color(0xFFE0F8EF) : const Color(0xFFFFE4E4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(r['state'] == 'ACCEPTED' ? 'Pago' : 'Rejeitado',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: r['state'] == 'ACCEPTED' ? const Color(0xFF0E8B66) : PagaliColors.danger)),
                  ),
                ]),
              ]),
            )).toList())),
          ],
        ]);
  }

  Widget _pendingCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PagaliColors.lime, width: 2),
        boxShadow: [BoxShadow(color: PagaliColors.lime.withValues(alpha: .15), blurRadius: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(r['merchantName'] ?? r['merchantId'], style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFFFF8E0), borderRadius: BorderRadius.circular(999)),
            child: const Text('PENDENTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB45309)))),
        ]),
        const SizedBox(height: 4),
        Text(r['description'] ?? '', style: PagaliText.caption),
        const SizedBox(height: 12),
        Text('${Money.cve(r['amount'] as num)} CVE',
          style: const TextStyle(fontFamily: PagaliText.family, fontSize: 32, fontWeight: FontWeight.w700, color: PagaliColors.purple)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: PButton(label: 'Rejeitar', fullWidth: true, variant: PButtonVariant.tertiary, onPressed: () => _reject(r))),
          const SizedBox(width: 12),
          Expanded(child: PButton(label: 'Pagar agora', fullWidth: true, onPressed: () => _accept(r))),
        ]),
      ]),
    );
  }
}
