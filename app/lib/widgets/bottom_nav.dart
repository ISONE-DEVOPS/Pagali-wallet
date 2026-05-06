// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class PagaliBottomNav extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;
  final VoidCallback onQR;
  final VoidCallback? onMerchantQR;

  const PagaliBottomNav({
    super.key, required this.active, required this.onChange, required this.onQR, this.onMerchantQR,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PagaliColors.bottomNav,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _navItem('home', Icons.home_outlined, 'Início'),
          _navItem('history', Icons.history, 'Histórico'),
          _qrFab(),
          _navItem('cards', Icons.credit_card, 'Cartões'),
          _navItem('more', Icons.menu, 'Mais'),
        ],
      ),
    );
  }

  Widget _navItem(String id, IconData icon, String label) {
    final on = active == id;
    return GestureDetector(
      onTap: () => onChange(id),
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: on ? 1 : 0.55,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(
                fontFamily: PagaliText.family, fontSize: 11, color: Colors.white,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrFab() {
    return GestureDetector(
      onTap: onQR,
      onLongPress: onMerchantQR,
      child: Transform.translate(
        offset: const Offset(0, -22),
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: PagaliColors.lime, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: PagaliColors.lime.withValues(alpha: .5), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: const Icon(Icons.qr_code_scanner, color: Color(0xFF1A1A1A), size: 26),
        ),
      ),
    );
  }
}
