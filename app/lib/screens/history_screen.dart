// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_card.dart';
import '../utils/format.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;
  const HistoryScreen({super.key, required this.transactions});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _Filter { all, sent, received, merchant }

class _HistoryScreenState extends State<HistoryScreen> {
  _Filter _filter = _Filter.all;

  bool _matches(Transaction t) => switch (_filter) {
    _Filter.all      => true,
    _Filter.sent     => t.kind == TxKind.p2pOut,
    _Filter.received => t.kind == TxKind.p2pIn || t.kind == TxKind.topup,
    _Filter.merchant => t.kind == TxKind.p2m,
  };

  @override
  Widget build(BuildContext context) {
    final txs = widget.transactions.where(_matches).toList();
    // group by ISO date string
    final groups = <String, List<Transaction>>{};
    for (final t in txs) {
      final k = DateFormat('yyyy-MM-dd').format(t.when);
      groups.putIfAbsent(k, () => []).add(t);
    }
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Histórico')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final f in _Filter.values) Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_label(f)),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  labelStyle: TextStyle(
                    fontFamily: PagaliText.family,
                    color: _filter == f ? Colors.white : PagaliColors.fgMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedColor: PagaliColors.purple,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x18000000)),
                  shape: const StadiumBorder(),
                ),
              ),
            ]),
          ),
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: keys.length,
          itemBuilder: (_, i) {
            final day = keys[i];
            final list = groups[day]!;
            final dateLabel = DateFormat('d \'de\' MMMM', 'pt_PT').format(DateTime.parse(day));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
                child: Text(dateLabel.toUpperCase(), style: PagaliText.label),
              ),
              PCard(padding: EdgeInsets.zero, child: Column(children: [
                for (int j = 0; j < list.length; j++) ...[
                  _txTile(list[j]),
                  if (j < list.length - 1) const Divider(height: 1, color: Color(0x10000000)),
                ],
              ])),
            ]);
          },
        )),
      ]),
    );
  }

  String _label(_Filter f) => switch (f) {
    _Filter.all => 'Todos', _Filter.sent => 'Enviados',
    _Filter.received => 'Recebidos', _Filter.merchant => 'QR',
  };

  Widget _txTile(Transaction t) {
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
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.counterparty.name, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15)),
          Text(DateFormat('HH:mm').format(t.when), style: PagaliText.caption),
        ])),
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
}
