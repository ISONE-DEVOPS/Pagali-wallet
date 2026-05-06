// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_avatar.dart';
import '../widgets/p_card.dart';
import '../widgets/bottom_nav.dart';
import '../utils/format.dart';
import '../models/transaction.dart';

typedef HomeAction = void Function(String key);

class HomeScreen extends StatefulWidget {
  final HomeAction onAction;
  final VoidCallback onQR;
  const HomeScreen({super.key, required this.onAction, required this.onQR});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _tab = 'home';
  bool _hideBalance = false;

  final _txs = <Transaction>[
    Transaction(kind: TxKind.p2pIn, counterparty: const TxParty(name: 'João Monteiro', idValue: '+238 989 0002'), amount: 1500, when: DateTime.now()),
    Transaction(kind: TxKind.p2m, counterparty: const TxParty(name: 'Restaurante Sodade', idValue: 'MER002'), amount: 850, when: DateTime.now()),
    Transaction(kind: TxKind.p2pOut, counterparty: const TxParty(name: 'Maria Tavares', idValue: '+238 989 0003'), amount: 2000, when: DateTime.now().subtract(const Duration(days: 1))),
    Transaction(kind: TxKind.p2pIn, counterparty: const TxParty(name: 'Carlos Évora', idValue: '+238 989 0004'), amount: 5000, when: DateTime.now().subtract(const Duration(days: 2))),
  ];

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
              _section('Movimentos recentes', _recentList(), action: 'Ver tudo'),
            ],
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: PagaliBottomNav(
              active: _tab,
              onChange: (id) => setState(() => _tab = id),
              onQR: widget.onQR,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      decoration: const BoxDecoration(
        color: PagaliColors.purple,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  PAvatar(
                    name: 'Ana Silva', size: 36,
                    background: Colors.white.withOpacity(.18), foreground: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bem-vinda', style: PagaliText.caption.copyWith(color: Colors.white70)),
                    Text('Ana Silva', style: PagaliText.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                  ]),
                ]),
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.12), shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(children: [
              Text('SALDO DISPONÍVEL', style: PagaliText.label.copyWith(color: Colors.white70)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _hideBalance = !_hideBalance),
                child: Icon(_hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16, color: Colors.white70),
              ),
            ]),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                _hideBalance ? '••••••' : Money.cve(5320),
                style: PagaliText.amount.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('CVE', style: PagaliText.bodySm.copyWith(color: Colors.white70, fontWeight: FontWeight.w500)),
              ),
            ]),
            Text('•••• 8821 · Banco de Cabo Verde', style: PagaliText.caption.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _quickActions() {
    Widget act(IconData i, String l, String a) => Expanded(child: GestureDetector(
      onTap: () => widget.onAction(a),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: PagaliColors.purple50, shape: BoxShape.circle),
            child: const Icon(null), // overridden below
          ).copyWithIcon(i),
          const SizedBox(height: 8),
          Text(l, style: PagaliText.caption.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 12)),
        ]),
      ),
    ));

    return PCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        _quickAction(Icons.arrow_upward, 'Enviar', 'send'),
        _quickAction(Icons.arrow_downward, 'Pedir', 'request'),
        _quickAction(Icons.qr_code_scanner, 'Pagar QR', 'qr'),
        _quickAction(Icons.add, 'Carregar', 'topup'),
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

  Widget _section(String title, Widget body, {String? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.toUpperCase(), style: PagaliText.label),
            if (action != null) Text(action, style: PagaliText.bodySm.copyWith(color: PagaliColors.purple, fontWeight: FontWeight.w500)),
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
    return PCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < _txs.length; i++) ...[
            _txRow(_txs[i]),
            if (i < _txs.length - 1) const Divider(height: 1, color: Color(0x10000000)),
          ],
        ],
      ),
    );
  }

  Widget _txRow(Transaction t) {
    final cfg = switch (t.kind) {
      TxKind.p2pIn  => (bg: const Color(0xFFE0F8EF), fg: const Color(0xFF0E8B66), icon: Icons.arrow_downward),
      TxKind.p2m    => (bg: const Color(0xFFFFF1D8), fg: const Color(0xFFA66800), icon: Icons.qr_code),
      TxKind.p2pOut => (bg: PagaliColors.purple50, fg: PagaliColors.purple, icon: Icons.arrow_upward),
      TxKind.topup  => (bg: const Color(0xFFE0F8EF), fg: const Color(0xFF0E8B66), icon: Icons.add),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: cfg.bg, shape: BoxShape.circle),
          child: Icon(cfg.icon, color: cfg.fg, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.counterparty.name, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15)),
            Text(_meta(t), style: PagaliText.caption),
          ],
        )),
        Text(
          (t.incoming ? '+' : '−') + Money.cve(t.amount),
          style: PagaliText.bodySm.copyWith(
            color: t.incoming ? const Color(0xFF0E8B66) : PagaliColors.fgDefault,
            fontWeight: FontWeight.w700, fontSize: 15,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ]),
    );
  }

  String _meta(Transaction t) {
    switch (t.kind) {
      case TxKind.p2pIn: return 'Recebido · há ${_ago(t.when)}';
      case TxKind.p2pOut: return 'Enviado · ${_ago(t.when)}';
      case TxKind.p2m: return 'QR · ${t.counterparty.name.contains('Sodade') ? 'Mindelo' : 'Praia'}';
      case TxKind.topup: return 'Carregamento';
    }
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'ontem';
    return '${diff.inDays} dias';
  }
}

// helper to set icon on a Container — keeps the home _quickActions readable
extension on Container {
  Container copyWithIcon(IconData icon) => this; // (vestigial — kept for older call site; not used)
}
