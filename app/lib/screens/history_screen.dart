// lib/screens/history_screen.dart — histórico real do backend
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_card.dart';
import '../utils/format.dart';
import '../services/api_client.dart';

class HistoryScreen extends StatefulWidget {
  final ApiClient api;
  const HistoryScreen({super.key, required this.api});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _Filter { all, p2p, p2m, g2p, fx }

class _HistoryScreenState extends State<HistoryScreen> {
  _Filter _filter = _Filter.all;
  List<Map<String, dynamic>> _txs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await widget.api.getTransfers();
      if (mounted) setState(() { _txs = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered => _txs.where((t) {
    final k = (t['kind'] as String? ?? 'P2P').toUpperCase();
    return switch (_filter) {
      _Filter.all => true,
      _Filter.p2p => k == 'P2P',
      _Filter.p2m => k == 'P2M',
      _Filter.g2p => k == 'G2P',
      _Filter.fx  => k == 'FX',
    };
  }).toList();

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final t in _filtered) {
      final raw = t['completedAt'] ?? t['createdAt'] ?? '';
      final day = raw.toString().length >= 10 ? raw.toString().substring(0, 10) : 'Hoje';
      groups.putIfAbsent(day, () => []).add(t);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped;
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Histórico'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
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
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: PagaliColors.purple))
          : _filtered.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.receipt_long_outlined, size: 48, color: PagaliColors.fgLight),
                const SizedBox(height: 12),
                Text('Sem transações', style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight)),
              ]))
            : RefreshIndicator(
                onRefresh: _load,
                color: PagaliColors.purple,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: keys.length,
                  itemBuilder: (_, i) {
                    final day = keys[i];
                    final list = groups[day]!;
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
                        child: Text(_dayLabel(day), style: PagaliText.label),
                      ),
                      PCard(padding: EdgeInsets.zero, child: Column(children: [
                        for (int j = 0; j < list.length; j++) ...[
                          _tile(list[j]),
                          if (j < list.length - 1) const Divider(height: 1, color: Color(0x10000000)),
                        ],
                      ])),
                    ]);
                  },
                ),
              ),
        ),
      ]),
    );
  }

  String _label(_Filter f) => switch (f) {
    _Filter.all => 'Todos', _Filter.p2p => 'P2P',
    _Filter.p2m => 'P2M',  _Filter.g2p => 'G2P', _Filter.fx => 'FX',
  };

  String _dayLabel(String iso) {
    try {
      final d = DateTime.parse(iso);
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) return 'HOJE';
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) { return iso; }
  }

  Widget _tile(Map<String, dynamic> t) {
    final kind = (t['kind'] as String? ?? 'P2P').toUpperCase();
    final (bg, fg, icon) = switch (kind) {
      'P2M' => (const Color(0xFFFFF1D8), const Color(0xFFA66800), Icons.qr_code),
      'G2P' => (const Color(0xFFE0F8EF), const Color(0xFF0E8B66), Icons.account_balance),
      'FX'  => (const Color(0xFFFFF3E0), const Color(0xFFB45309), Icons.currency_exchange),
      _     => (PagaliColors.purple50,    PagaliColors.purple,     Icons.arrow_upward),
    };
    final payee = t['payee'] as Map? ?? {};
    final payer = t['payer'] as Map? ?? {};
    final label = switch (kind) {
      'G2P' => 'Subsídio — ${payee['idValue'] ?? ''}',
      'FX'  => 'Remessa → ${payee['idValue'] ?? ''}',
      'P2M' => 'Comerciante ${payee['idValue'] ?? ''}',
      _     => '${payer['idValue'] ?? ''} → ${payee['idValue'] ?? ''}',
    };
    final time = () {
      try {
        final raw = t['completedAt'] ?? t['createdAt'] ?? '';
        final d = DateTime.parse(raw.toString()).toLocal();
        return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
      } catch (_) { return ''; }
    }();

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
          Text(label, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis),
          Text('$kind · $time', style: PagaliText.caption),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('−${Money.cve(t['amount'] as num)}', style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w700, fontSize: 15, fontFeatures: const [FontFeature.tabularFigures()])),
          Text('taxa ${Money.cve(num.tryParse(t['fee']?.toString() ?? '0') ?? 0)} CVE', style: PagaliText.caption),
        ]),
      ]),
    );
  }
}
