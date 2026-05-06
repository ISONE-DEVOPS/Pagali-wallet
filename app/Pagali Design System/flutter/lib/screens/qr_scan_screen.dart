// lib/screens/qr_scan_screen.dart  (P2M scanner — REAL camera via mobile_scanner)
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_client.dart';

class QRScanScreen extends StatefulWidget {
  final ApiClient api;
  final void Function(Map<String, dynamic>) onDetected;
  const QRScanScreen({super.key, required this.api, required this.onDetected});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final _controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool _busy = false;
  String? _error;

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_busy) return;
    final raw = cap.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    setState(() => _busy = true);
    try {
      // EMVCo TLV payload — server-side parse keeps client thin.
      final parsed = await widget.api.parseQr(raw);
      if (!mounted) return;
      widget.onDetected(parsed);
    } on ApiException catch (e) {
      setState(() { _error = 'QR inválido (${e.status})'; _busy = false; });
    } catch (e) {
      setState(() { _error = 'Erro a ler QR'; _busy = false; });
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pagar com QR', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.flash_on), onPressed: () => _controller.toggleTorch()),
          IconButton(icon: const Icon(Icons.cameraswitch), onPressed: () => _controller.switchCamera()),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),
        // viewfinder overlay
        Center(child: SizedBox(
          width: 240, height: 240,
          child: Stack(children: [
            for (final c in const [Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight])
              Align(alignment: c, child: _Corner(c)),
          ]),
        )),
        Positioned(
          left: 0, right: 0, bottom: 28,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _error ?? 'Aponte para o código do comerciante',
              textAlign: TextAlign.center,
              style: PagaliText.bodySm.copyWith(
                color: _error == null ? Colors.white70 : PagaliColors.lime,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment a;
  const _Corner(this.a);
  @override
  Widget build(BuildContext context) {
    final top = a.y < 0, left = a.x < 0;
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        border: Border(
          top:    top    ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
          bottom: !top   ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
          left:   left   ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
          right:  !left  ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
