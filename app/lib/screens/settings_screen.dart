// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_card.dart';
import '../widgets/p_avatar.dart';
import '../services/session.dart';

class SettingsScreen extends StatefulWidget {
  final Session session;
  final VoidCallback onSignOut;
  const SettingsScreen({super.key, required this.session, required this.onSignOut});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bio = true, _notif = true;

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user ?? const {'name': 'Ana Silva', 'msisdn': '+238 989 0001'};
    return Scaffold(
      backgroundColor: PagaliColors.bgApp,
      appBar: AppBar(title: const Text('Definições')),
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PCard(child: Row(children: [
            PAvatar(name: user['name'] as String, size: 56),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user['name'] as String, style: PagaliText.h3),
              Text(user['msisdn'] as String, style: PagaliText.caption),
            ])),
            const Icon(Icons.chevron_right, color: PagaliColors.fgLight),
          ])),
          const SizedBox(height: 20),
          _section('Segurança', [
            _link(Icons.lock_outline, 'Alterar PIN', () {}),
            _switch(Icons.fingerprint, 'Biometria', _bio, (v) => setState(() => _bio = v)),
            _link(Icons.shield_outlined, 'Verificação (KYC)', () {}, badge: 'Verificado', badgeColor: const Color(0xFF0E8B66)),
          ]),
          const SizedBox(height: 16),
          _section('Conta', [
            _link(Icons.account_balance, 'Bancos e cartões', () {}),
            _link(Icons.receipt_long_outlined, 'Extractos', () {}),
            _link(Icons.language, 'Idioma', () {}, trailing: 'Português'),
          ]),
          const SizedBox(height: 16),
          _section('Notificações', [
            _switch(Icons.notifications_outlined, 'Notificações push', _notif, (v) => setState(() => _notif = v)),
          ]),
          const SizedBox(height: 16),
          _section('Apoio', [
            _link(Icons.help_outline, 'Centro de ajuda', () {}),
            _link(Icons.policy_outlined, 'Privacidade e termos', () {}),
          ]),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () async {
              await widget.session.signOut();
              widget.onSignOut();
            },
            child: PCard(child: Center(child: Text('Terminar sessão', style: PagaliText.bodySm.copyWith(color: PagaliColors.danger, fontWeight: FontWeight.w500, fontSize: 15)))),
          ),
        ],
      )),
    );
  }

  Widget _section(String title, List<Widget> rows) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(2, 0, 2, 8), child: Text(title.toUpperCase(), style: PagaliText.label)),
    PCard(padding: EdgeInsets.zero, child: Column(children: [
      for (int i = 0; i < rows.length; i++) ...[
        rows[i],
        if (i < rows.length - 1) const Divider(height: 1, color: Color(0x10000000)),
      ],
    ])),
  ]);

  Widget _link(IconData icon, String label, VoidCallback onTap, {String? trailing, String? badge, Color? badgeColor}) {
    return InkWell(onTap: onTap, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: PagaliColors.fgMuted),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15))),
        if (badge != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: (badgeColor ?? PagaliColors.purple).withOpacity(.12), borderRadius: BorderRadius.circular(999)),
          child: Text(badge, style: TextStyle(fontFamily: PagaliText.family, fontSize: 11, color: badgeColor ?? PagaliColors.purple, fontWeight: FontWeight.w500)),
        ),
        if (trailing != null) Text(trailing, style: PagaliText.caption),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, size: 18, color: PagaliColors.fgLight),
      ]),
    ));
  }

  Widget _switch(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        Icon(icon, size: 20, color: PagaliColors.fgMuted),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: PagaliText.bodySm.copyWith(color: PagaliColors.fgDefault, fontWeight: FontWeight.w500, fontSize: 15))),
        Switch(value: value, onChanged: onChanged, activeThumbColor: PagaliColors.purple),
      ]),
    );
  }
}
