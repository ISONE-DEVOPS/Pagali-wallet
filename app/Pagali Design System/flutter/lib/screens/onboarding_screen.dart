// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/p_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardCopy('Fazer Pagamentos', 'Pague todas as suas contas em um único local. Sem fila e sem stress.', 'assets/images/onboard1.png'),
    _OnboardCopy('Segurança e Confiança', 'Monitoriza todas as suas transações.', 'assets/images/onboard2.png'),
    _OnboardCopy('Guarde os seus trocos', 'Poupa sem perceber, todos os dias.', 'assets/images/onboard3.png'),
    _OnboardCopy('Investimentos', 'Investe naquilo que acredita e confia.', 'assets/images/onboard4.png'),
    _OnboardCopy('Emite Faturas', 'Faça faturas para os seus clientes e receba logo.', 'assets/images/onboard5.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: PagaliColors.purple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/pagali.png', height: 28),
                  if (!isLast) GestureDetector(
                    onTap: widget.onDone,
                    child: const Text('Saltar', style: TextStyle(
                      fontFamily: PagaliText.family, color: Colors.white70, fontSize: 14,
                    )),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(p.image, height: 280, fit: BoxFit.contain),
                        Column(children: [
                          Text(p.title, textAlign: TextAlign.center, style: PagaliText.h2.copyWith(color: Colors.white)),
                          const SizedBox(height: 12),
                          Text(p.subtitle, textAlign: TextAlign.center, style: PagaliText.body.copyWith(color: Colors.white.withOpacity(.9))),
                        ]),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? Colors.white : Colors.white.withOpacity(.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                )),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PButton(
                    label: isLast ? 'Iniciar' : 'Próximo',
                    variant: PButtonVariant.lime,
                    onPressed: () => isLast
                      ? widget.onDone()
                      : _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardCopy {
  final String title, subtitle, image;
  const _OnboardCopy(this.title, this.subtitle, this.image);
}
