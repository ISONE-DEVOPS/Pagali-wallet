// lib/screens/pisp_screen.dart — PISP: Iniciação de Pagamentos por Terceiros
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../services/api_client.dart';
import '../services/wallet_service.dart';
import '../utils/format.dart';

class PispScreen extends StatefulWidget {
  final ApiClient api;
  final void Function(Map<String, dynamic>) onSuccess;
  const PispScreen({super.key, required this.api, required this.onSuccess});
  @override
  State<PispScreen> createState() => _PispScreenState();
}

class _PispScreenState extends State<PispScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(
        title: const Text('Iniciação de Pagamentos'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: PagaliColors.lime,
          labelColor: PagaliColors.purple,
          unselectedLabelColor: PagaliColors.fgLight,
          tabs: const [Tab(text: 'Apps'), Tab(text: 'Consentimentos'), Tab(text: 'Pedidos')],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _AppsTab(api: widget.api),
        _ConsentsTab(api: widget.api),
        _PendingTab(api: widget.api, onSuccess: widget.onSuccess),
      ]),
    );
  }
}

// ── Tab: Apps disponíveis ─────────────────────────────────────────────────────
class _AppsTab extends StatefulWidget {
  final ApiClient api;
  const _AppsTab({required this.api});
  @override State<_AppsTab> createState() => _AppsTabState();
}

class _AppsTabState extends State<_AppsTab> {
  List<Map<String, dynamic>> _apps = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await widget.api.getPispApps();
      if (mounted) setState(() => _apps = data);
    } catch (_) {}
  }

  Future<void> _grant(Map<String, dynamic> app) async {
    try {
      await widget.api.grantPispConsent(msisdn: '2389001', appId: app['appId'], maxAmount: 10000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Consentimento dado a ${app['name']}')),
      );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const PCard(child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('COMO FUNCIONA', style: PagaliText.label),
          SizedBox(height: 8),
          Text(
            'Autoriza apps de terceiros a iniciar pagamentos em teu nome via Pagali. '
            'Só apps autorizadas podem iniciar — és sempre notificado e podes aprovar ou rejeitar.',
            style: PagaliText.bodySm,
          ),
        ]),
      )),
      const SizedBox(height: 16),
      const Text('APPS DISPONÍVEIS', style: PagaliText.label),
      const SizedBox(height: 10),
      ..._apps.map((app) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: PagaliColors.purple.withValues(alpha: .07), blurRadius: 8)]),
        child: Row(children: [
          Text(app['icon'] ?? '📱', style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app['name'], style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(app['category'], style: PagaliText.caption),
            Text('Limite: até 10.000 CVE · Válido 30 dias', style: PagaliText.caption.copyWith(color: PagaliColors.fgLight)),
          ])),
          PButton(label: 'Autorizar', variant: PButtonVariant.lime, onPressed: () => _grant(app)),
        ]),
      )),
    ]);
  }
}

// ── Tab: Consentimentos activos ───────────────────────────────────────────────
class _ConsentsTab extends StatefulWidget {
  final ApiClient api;
  const _ConsentsTab({required this.api});
  @override State<_ConsentsTab> createState() => _ConsentsTabState();
}

class _ConsentsTabState extends State<_ConsentsTab> {
  List<Map<String, dynamic>> _consents = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await widget.api.getPispConsents('2389001');
      if (mounted) setState(() => _consents = data);
    } catch (_) {}
  }

  Future<void> _revoke(String consentId, String appName) async {
    await widget.api.revokePispConsent(consentId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Consentimento de $appName revogado')));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      if (_consents.isEmpty)
        PCard(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Icon(Icons.lock_outline, size: 48, color: PagaliColors.fgLight),
            const SizedBox(height: 8),
            Text('Sem consentimentos activos', style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight)),
            const Text('Vai ao separador "Apps" para autorizar', style: PagaliText.caption),
          ]),
        ))
      else ...[
        const Text('CONSENTIMENTOS ACTIVOS', style: PagaliText.label),
        const SizedBox(height: 10),
        ..._consents.map((c) {
          final app = c['app'] as Map? ?? {};
          final expires = c['expiresAt']?.toString().substring(0, 10) ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0F8EF), width: 2)),
            child: Row(children: [
              Text(app['icon'] ?? '📱', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app['name'] ?? c['appId'], style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600)),
                Text('Limite: ${Money.cve(c['maxAmount'] as num)} CVE · Expira $expires', style: PagaliText.caption),
                Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFE0F8EF), borderRadius: BorderRadius.circular(999)),
                  child: const Text('ACTIVO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0E8B66)))),
              ])),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: PagaliColors.danger, size: 22),
                onPressed: () => _revoke(c['consentId'], app['name'] ?? ''),
                tooltip: 'Revogar',
              ),
            ]),
          );
        }),
      ],
    ]);
  }
}

// ── Tab: Pedidos pendentes ────────────────────────────────────────────────────
class _PendingTab extends StatefulWidget {
  final ApiClient api;
  final void Function(Map<String, dynamic>) onSuccess;
  const _PendingTab({required this.api, required this.onSuccess});
  @override State<_PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<_PendingTab> {
  List<Map<String, dynamic>> _pending = [];
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() { super.initState(); _load(); _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load()); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _load() async {
    try {
      final data = await widget.api.getPispPending('2389001');
      if (mounted) setState(() { _pending = data; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _approve(Map<String, dynamic> r) async {
    final amount = r['amount'] as num;
    if (!WalletService.instance.canDebit(amount, amount * 0.005)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente'), backgroundColor: PagaliColors.danger),
      );
      }
      return;
    }
    try {
      final result = await widget.api.approvePisp(r['initiationId']);
      WalletService.instance.debit(amount, result['fee'] ?? 0);
      final app = r['app'] as Map? ?? {};
      if (mounted) {
        widget.onSuccess({
        'name': app['name'] ?? r['appId'],
        'phone': r['payeeMsisdn'] ?? '',
        'amount': amount,
        'transferId': result['transferId'],
        'kind': 'pisp',
      });
      }
    } catch (_) {}
  }

  Future<void> _reject(Map<String, dynamic> r) async {
    await widget.api.rejectPisp(r['initiationId']);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
      ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
      : ListView(padding: const EdgeInsets.all(20), children: [
          if (_pending.isEmpty)
            PCard(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Icon(Icons.inbox_outlined, size: 48, color: PagaliColors.fgLight),
                const SizedBox(height: 8),
                Text('Sem pedidos pendentes', style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight)),
                const Text('Autoriza uma app e simula um pedido via dashboard', style: PagaliText.caption),
              ]),
            ))
          else ...[
            const Text('AGUARDAM A TUA APROVAÇÃO', style: PagaliText.label),
            const SizedBox(height: 10),
            ..._pending.map((r) {
              final app = r['app'] as Map? ?? {};
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PagaliColors.purple, width: 2),
                  boxShadow: [BoxShadow(color: PagaliColors.purple.withValues(alpha: .1), blurRadius: 12)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(app['icon'] ?? '📱', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(app['name'] ?? r['appId'], style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(r['description'] ?? '', style: PagaliText.caption),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFFFF8E0), borderRadius: BorderRadius.circular(999)),
                      child: const Text('PISP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(
                    '${Money.cve(r['amount'] as num)} CVE',
                    style: const TextStyle(fontFamily: PagaliText.family, fontSize: 32, fontWeight: FontWeight.w700, color: PagaliColors.purple),
                  ),
                  if (r['reference'] != null)
                    Text('Ref: ${r['reference']}', style: PagaliText.caption.copyWith(color: PagaliColors.fgLight)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: PButton(label: 'Rejeitar', fullWidth: true, variant: PButtonVariant.tertiary, onPressed: () => _reject(r))),
                    const SizedBox(width: 12),
                    Expanded(child: PButton(label: 'Aprovar', fullWidth: true, onPressed: () => _approve(r))),
                  ]),
                ]),
              );
            }),
          ],
        ]);
  }
}
