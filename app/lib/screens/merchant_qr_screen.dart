// lib/screens/merchant_qr_screen.dart — QR do comerciante
import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_client.dart';

class MerchantQRScreen extends StatefulWidget {
  final ApiClient api;
  const MerchantQRScreen({super.key, required this.api});
  @override
  State<MerchantQRScreen> createState() => _MerchantQRScreenState();
}

class _MerchantQRScreenState extends State<MerchantQRScreen> {
  static const _merchants = [
    {'id': 'MER001', 'name': 'Mercado Sucupira', 'city': 'Praia',   'fsp': 'BCVCVCV', 'mcc': '5411'},
    {'id': 'MER002', 'name': 'Restaurante Sodade','city': 'Mindelo', 'fsp': 'BCVCVCV', 'mcc': '5812'},
  ];

  Map<String, String> _selected = _merchants.first;
  Map<String, dynamic>? _qr;
  bool _loading = false;

  @override
  void initState() { super.initState(); _generate(); }

  Future<void> _generate() async {
    setState(() { _loading = true; _qr = null; });
    try {
      final res = await widget.api.generateQR(
        merchantId: _selected['id']!,
        dfspSwift: _selected['fsp']!,
        merchantName: _selected['name']!,
        merchantCity: _selected['city']!,
        mcc: _selected['mcc'],
      );
      if (mounted) setState(() { _qr = res; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgBytes = _qr != null
      ? base64Decode((_qr!['qrImage'] as String).replaceFirst('data:image/png;base64,', ''))
      : null;

    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('QR do Comerciante')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        // Selector de comerciante
        Row(mainAxisAlignment: MainAxisAlignment.center, children: _merchants.map((m) {
          final sel = _selected['id'] == m['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () { setState(() => _selected = m); _generate(); },
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

        const SizedBox(height: 28),

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
              const SizedBox(height: 280, child: Center(child: CircularProgressIndicator(color: PagaliColors.purple)))
            else if (imgBytes != null)
              Image.memory(imgBytes, width: 260, height: 260, fit: BoxFit.contain)
            else
              const SizedBox(height: 280, child: Center(child: Icon(Icons.qr_code_2, size: 80, color: PagaliColors.fgLight))),

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

        const SizedBox(height: 24),
        if (_qr != null) ...[
          const Text('CÓDIGO QR', style: PagaliText.label),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Text(
              _qr!['qrString'] as String,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: PagaliColors.fgMuted),
            ),
          ),
        ],
      ]),
    );
  }
}
