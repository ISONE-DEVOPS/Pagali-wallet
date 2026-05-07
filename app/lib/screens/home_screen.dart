// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_avatar.dart';
import '../widgets/p_card.dart';
import '../widgets/bottom_nav.dart';
import '../utils/format.dart';
import '../services/wallet_service.dart';
import '../services/api_client.dart';


typedef HomeAction = void Function(String key);

class HomeScreen extends StatefulWidget {
  final HomeAction onAction;
  final VoidCallback onQR;
  final VoidCallback onHistory;
  final ApiClient api;
  const HomeScreen({super.key, required this.onAction, required this.onQR, required this.onHistory, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _tab = 'home';
  bool _hideBalance = false;
  List<Map<String, dynamic>> _recent = [];

  @override
  void initState() { super.initState(); _loadRecent(); }

  Future<void> _loadRecent() async {
    try {
      final txs = await widget.api.getTransfers();
      if (mounted) setState(() => _recent = txs.take(5).toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _hero(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Transform.translate(offset: const Offset(0, -22), child: _quickActions()),
              ),
              const SizedBox(height: 8),
              _section('Pagar contas', _billPayGrid()),
              _section('Movimentos recentes', _recentList(), action: 'Ver tudo', onAction: widget.onHistory),
              _section('Mais Serviços', _extraServices()),
            ],
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: PagaliBottomNav(
              active: _tab,
              onChange: (id) {
                setState(() => _tab = id);
                if (id == 'history') widget.onHistory();
              },
              onQR: widget.onQR,
              onMerchantQR: () => widget.onAction('myqr'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B3FBF), PagaliColors.purple, Color(0xFF4F2A82)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + notificações
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                PAvatar(
                  name: 'Ana Silva', size: 40,
                  background: Colors.white.withValues(alpha: .2),
                  foreground: Colors.white,
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Bem-vinda 👋', style: PagaliText.caption.copyWith(color: Colors.white60, fontSize: 12)),
                  Text('Ana Silva', style: PagaliText.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ]),
              ]),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
              ),
            ]),

            const SizedBox(height: 28),

            // Label saldo
            Row(children: [
              Text('SALDO DISPONÍVEL', style: PagaliText.label.copyWith(color: Colors.white54, letterSpacing: .08)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _hideBalance = !_hideBalance),
                child: Icon(
                  _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 15, color: Colors.white54,
                ),
              ),
            ]),

            const SizedBox(height: 6),

            // Valor principal
            ValueListenableBuilder<num>(
              valueListenable: WalletService.instance.balance,
              builder: (_, bal, __) => Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _hideBalance ? '••••••' : Money.cve(bal),
                    style: const TextStyle(
                      fontFamily: PagaliText.family,
                      fontSize: 42, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: -1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text('CVE', style: PagaliText.bodySm.copyWith(
                      color: PagaliColors.lime, fontWeight: FontWeight.w700, fontSize: 14,
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Chip do cartão
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: .15)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.credit_card_outlined, color: Colors.white70, size: 15),
                const SizedBox(width: 8),
                Text('•••• 8821', style: PagaliText.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(width: 6),
                Text('·', style: PagaliText.caption.copyWith(color: Colors.white38)),
                const SizedBox(width: 6),
                Text('Banco de Cabo Verde', style: PagaliText.caption.copyWith(color: Colors.white60)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions() {
    return PCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        _quickAction(Icons.arrow_upward,      'Enviar',  'send'),
        _quickAction(Icons.qr_code_2,         'Meu QR',  'myqr'),
        _quickAction(Icons.account_balance,   'G2P',     'g2p'),
        _quickAction(Icons.currency_exchange, 'Remessa', 'fx'),
      ]),
    );
  }

  Widget _quickAction(IconData icon, String label, String action) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onAction(action),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(children: [
            Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: PagaliColors.purple50, shape: BoxShape.circle),
              child: Icon(icon, color: PagaliColors.purple, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, style: PagaliText.caption.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _extraServices() {
    final services = [
      (
        icon: Icons.request_page_outlined,
        color: PagaliColors.purple,
        bg: PagaliColors.purple50,
        title: 'Request to Pay',
        sub: 'Comerciante envia pedido · cliente confirma com 1 toque',
        action: 'r2p',
      ),
      (
        icon: Icons.storefront_outlined,
        color: const Color(0xFF0E8B66),
        bg: const Color(0xFFE0F8EF),
        title: 'Agent Banking',
        sub: 'Cash-in e cash-out nas ilhas sem banco',
        action: 'agent',
      ),
      (
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFB45309),
        bg: const Color(0xFFFFF3E0),
        title: 'Impostos',
        sub: 'Pagar IGT, INPS, IVA e outros impostos',
        action: 'tax',
      ),
      (
        icon: Icons.currency_bitcoin,
        color: const Color(0xFF1a0a2e),
        bg: const Color(0xFFEDE7F6),
        title: 'Escudo Digital (CBDC)',
        sub: 'Moeda digital emitida pelo BCV — 1:1 com CVE',
        action: 'cbdc',
      ),
    ];
    return Column(children: services.map((s) => GestureDetector(
      onTap: () => widget.onAction(s.action),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 8)],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(s.icon, color: s.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.title, style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(s.sub, style: PagaliText.caption),
          ])),
          const Icon(Icons.chevron_right, color: PagaliColors.fgLight, size: 20),
        ]),
      ),
    )).toList());
  }

  Widget _section(String title, Widget body, {String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.toUpperCase(), style: PagaliText.label),
            if (action != null)
              GestureDetector(
                onTap: onAction,
                child: Text(action, style: PagaliText.bodySm.copyWith(color: PagaliColors.purple, fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        body,
      ]),
    );
  }

  Widget _billPayGrid() {
    final bills = [
      ('Electra', 'Luz', const Color(0xFFFFE9B0), const Color(0xFF8A6100)),
      ('CV Telecom', 'Internet', const Color(0xFFDDF2FF), PagaliColors.linkBlue),
      ('IGT', 'Impostos', PagaliColors.purple50, PagaliColors.purple),
    ];
    return Row(children: [
      for (final b in bills) ...[
        Expanded(child: PCard(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: b.$3, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(b.$1[0], style: TextStyle(fontFamily: PagaliText.family, color: b.$4, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Text(b.$1, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500)),
            Text(b.$2, style: PagaliText.caption),
          ]),
        )),
        if (b != bills.last) const SizedBox(width: 10),
      ],
    ]);
  }

  Widget _recentList() {
    if (_recent.isEmpty) {
      return PCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text('Sem movimentos ainda', style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight)),
          ),
        ),
      );
    }
    return PCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (int i = 0; i < _recent.length; i++) ...[
          _txRow(_recent[i]),
          if (i < _recent.length - 1) const Divider(height: 1, color: Color(0x10000000)),
        ],
      ]),
    );
  }

  Widget _txRow(Map<String, dynamic> t) {
    final kind = (t['kind'] as String? ?? 'P2P').toUpperCase();
    final (bg, fg, icon) = switch (kind) {
      'P2M' => (const Color(0xFFFFF1D8), const Color(0xFFA66800), Icons.qr_code),
      'G2P' => (const Color(0xFFE0F8EF), const Color(0xFF0E8B66), Icons.account_balance),
      'FX'  => (const Color(0xFFFFF3E0), const Color(0xFFB45309), Icons.currency_exchange),
      _     => (PagaliColors.purple50,    PagaliColors.purple,     Icons.arrow_upward),
    };
    final payee = (t['payee'] as Map?)??{};
    final label = switch (kind) {
      'P2M' => 'Comerciante ${payee['idValue'] ?? ''}',
      'G2P' => 'Subsídio → ${payee['idValue'] ?? ''}',
      'FX'  => 'Remessa → ${payee['idValue'] ?? ''}',
      _     => '→ ${payee['idValue'] ?? ''}',
    };
    final subtitle = '$kind · ${_timeAgo(t['completedAt'] ?? t['createdAt'] ?? '')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: fg, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15), overflow: TextOverflow.ellipsis),
          Text(subtitle, style: PagaliText.caption),
        ])),
        Text(
          '−${Money.cve(t['amount'] as num)}',
          style: PagaliText.bodySm.copyWith(
            color: PagaliColors.fgDefault,
            fontWeight: FontWeight.w700, fontSize: 15,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ]),
    );
  }

  String _timeAgo(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return 'agora';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays == 1) return 'ontem';
      return '${diff.inDays} dias';
    } catch (_) { return ''; }
  }
}
