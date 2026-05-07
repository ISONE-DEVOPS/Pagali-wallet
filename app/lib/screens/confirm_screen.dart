// lib/screens/confirm_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';
import '../widgets/p_card.dart';
import '../widgets/p_avatar.dart';
import '../utils/format.dart';
import '../services/wallet_service.dart';

class ConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> tx;
  final Future<void> Function() onConfirm;
  const ConfirmScreen({super.key, required this.tx, required this.onConfirm});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _handleConfirm() async {
    setState(() { _loading = true; _error = null; });
    try {
      await widget.onConfirm();
    } on InsufficientBalanceException catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Falha no pagamento. Tente novamente.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final amt = (widget.tx['amount'] as num);
    final fee = (amt * 0.005);
    final total = amt + fee;
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Confirmar')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 12),
            PAvatar(name: widget.tx['name'], size: 72),
            const SizedBox(height: 14),
            const Text('A enviar a', style: PagaliText.caption),
            const SizedBox(height: 4),
            Text(widget.tx['name'], style: PagaliText.h3),
            Text(widget.tx['phone'] ?? '', style: PagaliText.caption),
            const SizedBox(height: 20),
            PCard(child: Column(children: [
              _row('Montante', '${Money.cve(amt)} CVE'),
              _row('Taxa (0,5%)', '${Money.cve(fee)} CVE'),
              const Divider(height: 16, color: Color(0x10000000)),
              _row('Total', '${Money.cve(total)} CVE', emphasis: true),
              if ((widget.tx['note'] as String?)?.isNotEmpty == true) ...[
                const Divider(height: 16, color: Color(0x10000000)),
                const Align(alignment: Alignment.centerLeft, child: Text('Nota', style: PagaliText.caption)),
                const SizedBox(height: 2),
                Align(alignment: Alignment.centerLeft, child: Text(widget.tx['note'], style: PagaliText.bodySm)),
              ],
            ])),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: PagaliColors.danger, fontSize: 13)),
            ],
            const Spacer(),
            _loading
              ? const CircularProgressIndicator(color: PagaliColors.purple)
              : PButton(label: 'Pagar agora', fullWidth: true, onPressed: _handleConfirm),
            const SizedBox(height: 12),
            PButton(
              label: 'Cancelar', fullWidth: true,
              variant: PButtonVariant.tertiary,
              onPressed: _loading ? null : () => Navigator.of(context).pop(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(String l, String r, {bool emphasis = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: PagaliText.bodySm.copyWith(color: emphasis ? PagaliColors.fgDefault : PagaliColors.fgLight, fontSize: 14)),
        Text(r, style: emphasis
          ? const TextStyle(fontFamily: PagaliText.family, fontWeight: FontWeight.w700, color: PagaliColors.purple, fontFeatures: [FontFeature.tabularFigures()])
          : PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }
}
