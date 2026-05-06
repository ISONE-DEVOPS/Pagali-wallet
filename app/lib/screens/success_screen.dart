// lib/screens/success_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../utils/format.dart';

class SuccessScreen extends StatefulWidget {
  final Map<String, dynamic> tx;
  final VoidCallback onDone;
  const SuccessScreen({super.key, required this.tx, required this.onDone});
  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 40),
    ]).animate(_ctrl);
    _fade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)));
    Timer(const Duration(milliseconds: 100), _ctrl.forward);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final amt = widget.tx['amount'] as num;
    final txId = widget.tx['transferId'] as String?;
    final name = widget.tx['name'] as String? ?? '';
    final kind = (widget.tx['kind'] as String? ?? 'p2p').toLowerCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(),
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 96, height: 96,
              decoration: const BoxDecoration(color: Color(0xFFE0F8EF), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Color(0xFF0E8B66), size: 52),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(opacity: _fade, child: Column(children: [
            Text(
              kind == 'fx' ? 'Remessa enviada!' : 'Pagamento concluído!',
              style: PagaliText.h3,
            ),
            const SizedBox(height: 8),
            Text(
              name.isNotEmpty
                ? '${Money.cve(amt)} CVE ${kind == 'fx' ? 'enviados para' : 'enviados a'} $name.'
                : '${Money.cve(amt)} CVE processados com sucesso.',
              textAlign: TextAlign.center,
              style: PagaliText.bodySm.copyWith(color: PagaliColors.fgLight),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: PagaliColors.purple50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'ID: ${txId?.substring(0, 16).toUpperCase() ?? 'N/A'}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: PagaliColors.purple),
              ),
            ),
          ])),
          const Spacer(),
          FadeTransition(opacity: _fade, child: Column(children: [
            Row(children: [
              Expanded(child: PButton(label: 'Partilhar', variant: PButtonVariant.tertiary, icon: Icons.share_outlined, onPressed: () {}, fullWidth: true)),
              const SizedBox(width: 10),
              Expanded(child: PButton(label: 'Recibo', variant: PButtonVariant.tertiary, icon: Icons.receipt_long_outlined, onPressed: () {}, fullWidth: true)),
            ]),
            const SizedBox(height: 12),
            PButton(label: 'Voltar ao início', fullWidth: true, onPressed: widget.onDone),
          ])),
        ]),
      )),
    );
  }
}
