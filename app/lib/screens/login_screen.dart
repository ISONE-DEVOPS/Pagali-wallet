// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_avatar.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const LoginScreen({super.key, required this.onAuthenticated});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';

  void _press(String k) {
    if (k == 'del') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
      return;
    }
    if (_pin.length >= 4) return;
    setState(() => _pin += k);
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 250), widget.onAuthenticated);
    }
  }

  Widget _key(String k) {
    return Material(
      color: Colors.white.withOpacity(.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _press(k),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: k == 'del'
            ? const Icon(Icons.backspace_outlined, color: Colors.white)
            : Text(k, style: const TextStyle(
                fontFamily: PagaliText.family, color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PagaliColors.purple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/pagali.png', height: 26, alignment: Alignment.centerLeft),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PAvatar(
                      name: 'Ana Silva', size: 72,
                      background: Colors.white.withOpacity(.18),
                      foreground: Colors.white,
                    ),
                    const SizedBox(height: 18),
                    Text('Olá, Ana', style: PagaliText.h3.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Insira o seu PIN para entrar', style: PagaliText.bodySm.copyWith(color: Colors.white70)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _pin.length > i ? Colors.white : Colors.transparent,
                          border: Border.all(color: Colors.white.withOpacity(.6), width: 2),
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              GridView.count(
                crossAxisCount: 3, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8, mainAxisSpacing: 8,
                childAspectRatio: 2.1,
                children: [
                  ...['1','2','3','4','5','6','7','8','9'].map(_key),
                  const SizedBox.shrink(), _key('0'), _key('del'),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onAuthenticated,
                child: Text('Entrar em modo demo', style: TextStyle(color: Colors.white.withValues(alpha: .5), fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
