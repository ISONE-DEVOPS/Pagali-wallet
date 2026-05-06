// lib/main.dart — Pagali wallet entry point.

import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'theme/colors.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/send_screen.dart';
import 'screens/confirm_screen.dart';
import 'screens/success_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/merchant_pay_screen.dart';
import 'services/api_client.dart';

final _api = ApiClient();

void main() => runApp(const PagaliApp());

class PagaliApp extends StatelessWidget {
  const PagaliApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagali',
      debugShowCheckedModeBanner: false,
      theme: buildPagaliTheme(),
      home: const _Splash(),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _gotoOnboarding);
  }

  void _gotoOnboarding() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => OnboardingScreen(onDone: _gotoLogin),
    ));
  }

  void _gotoLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => LoginScreen(onAuthenticated: _gotoHome),
    ));
  }

  void _gotoHome() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => HomeScreen(
        onAction: (a) {
          if (a == 'send') _gotoSend(context);
          if (a == 'qr') _gotoQR(context);
          // request, topup → wire when implemented
        },
        onQR: () => _gotoQR(context),
      ),
    ));
  }

  void _gotoSend(BuildContext c) {
    Navigator.of(c).push(MaterialPageRoute(
      builder: (_) => SendScreen(onContinue: (tx) => _gotoConfirm(c, tx)),
    ));
  }

  void _gotoConfirm(BuildContext c, Map<String, dynamic> tx) {
    Navigator.of(c).push(MaterialPageRoute(
      builder: (_) => ConfirmScreen(tx: tx, onConfirm: () => _gotoSuccess(c, tx)),
    ));
  }

  void _gotoSuccess(BuildContext c, Map<String, dynamic> tx) {
    Navigator.of(c).pushReplacement(MaterialPageRoute(
      builder: (_) => SuccessScreen(tx: tx, onDone: () => Navigator.of(c).popUntil((r) => r.isFirst)),
    ));
  }

  void _gotoQR(BuildContext c) {
    Navigator.of(c).push(MaterialPageRoute(
      builder: (_) => QRScanScreen(api: _api, onDetected: (m) => _gotoMerchantPay(c, m)),
    ));
  }

  void _gotoMerchantPay(BuildContext c, Map<String, dynamic> m) {
    Navigator.of(c).pushReplacement(MaterialPageRoute(
      builder: (_) => MerchantPayScreen(merchant: m, onPay: (tx) => _gotoSuccess(c, tx)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PagaliColors.purple,
        image: DecorationImage(
          image: AssetImage('assets/images/splashMain.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
