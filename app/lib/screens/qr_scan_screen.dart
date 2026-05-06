// lib/screens/qr_scan_screen.dart
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
  MobileScannerController? _controller;
  bool _cameraAvailable = false;
  bool _busy = false;
  String? _error;

  static const _demoQR =
      '00020101021126390014com.pagali.p2m0107BCVCVCV0206MER0015204541153031325802CV5916Mercado Sucupira6005Praia6304ABB4';

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final ctrl = MobileScannerController(formats: [BarcodeFormat.qrCode]);
      await ctrl.start();
      if (mounted) setState(() { _controller = ctrl; _cameraAvailable = true; });
    } catch (_) {
      if (mounted) setState(() => _cameraAvailable = false);
    }
  }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_busy) return;
    final raw = cap.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    await _parse(raw);
  }

  Future<void> _simulateQR() => _parse(_demoQR);

  Future<void> _parse(String qrString) async {
    setState(() { _busy = true; _error = null; });
    try {
      final parsed = await widget.api.parseQr(qrString);
      if (!mounted) return;
      widget.onDetected(parsed);
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = 'QR inválido (${e.status})'; _busy = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Erro a ler QR'; _busy = false; });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pagar com QR', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: _cameraAvailable ? [
          IconButton(icon: const Icon(Icons.flash_on), onPressed: () => _controller?.toggleTorch()),
          IconButton(icon: const Icon(Icons.cameraswitch), onPressed: () => _controller?.switchCamera()),
        ] : [],
      ),
      extendBodyBehindAppBar: true,
      body: _cameraAvailable ? _cameraView() : _noCamera(),
    );
  }

  Widget _cameraView() {
    return Stack(children: [
      MobileScanner(controller: _controller!, onDetect: _onDetect),
      Center(child: SizedBox(
        width: 240, height: 240,
        child: Stack(children: [
          for (final c in const [Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight])
            Align(alignment: c, child: _Corner(c)),
        ]),
      )),
      _bottomBar(),
    ]);
  }

  Widget _noCamera() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.qr_code_scanner, color: PagaliColors.lime, size: 80),
      const SizedBox(height: 24),
      const Text('Câmara não disponível', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('(emulador / simulador)', style: TextStyle(color: Colors.white54, fontSize: 13)),
      const SizedBox(height: 40),
      if (_error != null) ...[
        Text(_error!, style: const TextStyle(color: PagaliColors.lime, fontSize: 13)),
        const SizedBox(height: 16),
      ],
      _busy
        ? const CircularProgressIndicator(color: PagaliColors.lime)
        : ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: PagaliColors.lime, foregroundColor: Colors.black),
            onPressed: _simulateQR,
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Simular QR — Mercado Sucupira'),
          ),
    ]);
  }

  Widget _bottomBar() {
    return Positioned(
      left: 0, right: 0, bottom: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            _error ?? 'Aponte para o código do comerciante',
            textAlign: TextAlign.center,
            style: PagaliText.bodySm.copyWith(
              color: _error == null ? Colors.white70 : PagaliColors.lime,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _busy ? null : _simulateQR,
            icon: const Icon(Icons.qr_code_2, color: PagaliColors.lime, size: 18),
            label: const Text('Simular QR (demo)', style: TextStyle(color: PagaliColors.lime, fontSize: 13)),
          ),
        ]),
      ),
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
          top:    top  ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
          left:   left  ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
          right:  !left ? const BorderSide(color: PagaliColors.lime, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
