// lib/screens/merchant_qr_screen.dart — QR e saldo do comerciante
import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_client.dart';
import '../utils/format.dart';

class MerchantQRScreen extends StatefulWidget {
  final ApiClient api;
  const MerchantQRScreen({super.key, required this.api});
  @override
  State<MerchantQRScreen> createState() => _MerchantQRScreenState();
}

class _MerchantQRScreenState extends State<MerchantQRScreen> {
  static const _merchants = [
    {'id': 'MER001', 'name': 'Mercado Sucupira',  'city': 'Praia',   'fsp': 'BCVCVCV', 'mcc': '5411'},
    {'id': 'MER002', 'name': 'Restaurante Sodade', 'city': 'Mindelo', 'fsp': 'BCVCVCV', 'mcc': '5812'},
  ];

  Map<String, String> _selected = _merchants.first;
  Map<String, dynamic>? _qr;
  Map<String, dynamic>? _merchant;
  List<Map<String, dynamic>> _payments = [];
  bool _loading = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _qr = null; });
    try {
      final results = await Future.wait([
        widget.api.generateQR(
          merchantId: _selected['id']!,
          dfspSwift:  _selected['fsp']!,
          merchantName: _selected['name']!,
          merchantCity: _selected['city']!,
          mcc: _selected['mcc'],
        ),
        widget.api.getMerchant(_selected['id']!),
        widget.api.getMerchantPayments(_selected['id']!),
      ]);
      if (!mounted) return;
      setState(() {
        _qr       = results[0] as Map<String, dynamic>;
        _merchant = results[1] as Map<String, dynamic>;
        _payments = (results[2] as List).cast<Map<String, dynamic>>();
        _loading  = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshBalance() async {
    try {
      final m = await widget.api.getMerchant(_selected['id']!);
      final p = await widget.api.getMerchantPayments(_selected['id']!);
      if (mounted) setState(() { _merchant = m; _payments = p; });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final imgBytes = _qr != null
      ? base64Decode((_qr!['qrImage'] as String).replaceFirst('data:image/png;base64,', ''))
      : null;
    final balance = (_merchant?['balance'] as num?) ?? 0;

    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(
        title: const Text('QR do Comerciante'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshBalance)],
      ),
      body: ListView(padding: const EdgeInsets.all(24), children: [

        // Selector
        Row(mainAxisAlignment: MainAxisAlignment.center, children: _merchants.map((m) {
          final sel = _selected['id'] == m['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () { setState(() => _selected = m); _load(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? PagaliColors.purple : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? PagaliColors.purple : const Color(0x20000000)),
                ),
                child: Text(m['name']!, style: TextStyle(
                  fontFamily: PagaliText.family, fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : PagaliColors.fgDefault,
                )),
              ),
            ),
          );
        }).toList()),

        const SizedBox(height: 20),

        // Saldo do comerciante
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PagaliColors.purple,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SALDO RECEBIDO', style: PagaliText.label.copyWith(color: Colors.white60)),
              const SizedBox(height: 4),
              Text('${Money.cve(balance)} CVE', style: PagaliText.amount.copyWith(color: Colors.white, fontSize: 28)),
              Text('${_payments.length} pagamentos recebidos', style: PagaliText.caption.copyWith(color: Colors.white60)),
            ]),
            const Icon(Icons.storefront_outlined, color: Colors.white38, size: 40),
          ]),
        ),

        const SizedBox(height: 20),

        // QR Code
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: PagaliColors.purple.withValues(alpha: .15), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(children: [
            if (_loading)
              const SizedBox(height: 260, child: Center(child: CircularProgressIndicator(color: PagaliColors.purple)))
            else if (imgBytes != null)
              Image.memory(imgBytes, width: 240, height: 240, fit: BoxFit.contain)
            else
              const SizedBox(height: 260, child: Center(child: Icon(Icons.qr_code_2, size: 80, color: PagaliColors.fgLight))),

            const SizedBox(height: 16),
            Text(_selected['name']!, style: PagaliText.h3),
            Text('${_selected['city']} · MCC ${_selected['mcc']}', style: PagaliText.caption),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE0F8EF), borderRadius: BorderRadius.circular(999)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shield_outlined, size: 12, color: Color(0xFF0E8B66)),
                SizedBox(width: 4),
                Text('Verificado · EMVCo', style: TextStyle(fontFamily: PagaliText.family, fontSize: 11, color: Color(0xFF0E8B66), fontWeight: FontWeight.w500)),
              ]),
            ),
          ]),
        ),

        // Últimos pagamentos
        if (_payments.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('ÚLTIMOS PAGAMENTOS', style: PagaliText.label),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              for (int i = 0; i < _payments.take(5).length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Pagamento recebido', style: PagaliText.bodySm.copyWith(fontWeight: FontWeight.w500)),
                      Text(
                        (_payments[i]['transferId'] as String? ?? '').substring(0, 8).toUpperCase(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: PagaliColors.fgLight),
                      ),
                    ]),
                    Text(
                      '+${Money.cve(_payments[i]['amount'] as num)} CVE',
                      style: PagaliText.bodySm.copyWith(color: const Color(0xFF0E8B66), fontWeight: FontWeight.w700),
                    ),
                  ]),
                ),
                if (i < _payments.take(5).length - 1) const Divider(height: 1, color: Color(0x10000000)),
              ],
            ]),
          ),
        ],

        // QR String
        if (_qr != null) ...[
          const SizedBox(height: 20),
          const Text('CÓDIGO QR (TLV)', style: PagaliText.label),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Text(_qr!['qrString'] as String, style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: PagaliColors.fgMuted)),
          ),
        ],
      ]),
    );
  }
}
