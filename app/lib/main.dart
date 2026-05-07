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
import 'screens/g2p_screen.dart';
import 'screens/fx_screen.dart';
import 'screens/history_screen.dart';
import 'screens/merchant_qr_screen.dart';
import 'screens/r2p_screen.dart';
import 'screens/agent_screen.dart';
import 'services/api_client.dart';
import 'services/transfer_service.dart';
import 'services/wallet_service.dart';

final _navigatorKey = GlobalKey<NavigatorState>();
final _api = ApiClient();
final _transfer = TransferService(_api);

NavigatorState get _nav => _navigatorKey.currentState!;

void main() => runApp(const PagaliApp());

class PagaliApp extends StatelessWidget {
  const PagaliApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagali',
      debugShowCheckedModeBanner: false,
      theme: buildPagaliTheme(),
      navigatorKey: _navigatorKey,
      home: const _Splash(),
    );
  }
}

// ── Navigation helpers ────────────────────────────────────────────────────────

void _gotoOnboarding() {
  _nav.pushReplacement(MaterialPageRoute(
    builder: (_) => const OnboardingScreen(onDone: _gotoLogin),
  ));
}

void _gotoLogin() {
  _nav.pushReplacement(MaterialPageRoute(
    builder: (_) => const LoginScreen(onAuthenticated: _gotoHome),
  ));
}

void _gotoHome() {
  _nav.pushReplacement(MaterialPageRoute(
    builder: (_) => HomeScreen(
      api: _api,
      onAction: (a) {
        if (a == 'send')    _gotoSend();
        if (a == 'qr')     _gotoQR();
        if (a == 'g2p')    _gotoG2P();
        if (a == 'fx')     _gotoFX();
        if (a == 'myqr')   _gotoMerchantQR();
        if (a == 'history') _gotoHistory();
        if (a == 'r2p')    _gotoR2P();
        if (a == 'agent')  _gotoAgent();
      },
      onQR: _gotoQR,
      onHistory: _gotoHistory,
    ),
  ));
}

void _gotoG2P() {
  _nav.push(MaterialPageRoute(builder: (_) => G2PScreen(api: _api)));
}

void _gotoFX() {
  _nav.push(MaterialPageRoute(
    builder: (_) => FxScreen(api: _api, onSuccess: _gotoSuccess),
  ));
}

void _gotoHistory() {
  _nav.push(MaterialPageRoute(
    builder: (_) => HistoryScreen(api: _api),
  ));
}

void _gotoMerchantQR() {
  _nav.push(MaterialPageRoute(
    builder: (_) => MerchantQRScreen(api: _api),
  ));
}

void _gotoR2P() {
  _nav.push(MaterialPageRoute(
    builder: (_) => R2PScreen(api: _api, onSuccess: _gotoSuccess),
  ));
}

void _gotoAgent() {
  _nav.push(MaterialPageRoute(
    builder: (_) => AgentScreen(api: _api),
  ));
}

void _gotoSend() {
  _nav.push(MaterialPageRoute(
    builder: (_) => const SendScreen(onContinue: _gotoConfirm),
  ));
}

void _gotoConfirm(Map<String, dynamic> tx) {
  _nav.push(MaterialPageRoute(
    builder: (_) => ConfirmScreen(
      tx: tx,
      onConfirm: () async {
        final receipt = await _transfer.sendP2P(
          payerMsisdn: '2389001',
          payeeMsisdn: tx['msisdn'] as String,
          amount: tx['amount'] as num,
          note: tx['note'] as String?,
        );
        final fee = num.tryParse(receipt['fee']?.toString() ?? '0') ?? 0;
        WalletService.instance.debit(tx['amount'] as num, fee);
        _gotoSuccess({...tx, ...receipt});
      },
    ),
  ));
}

void _gotoSuccess(Map<String, dynamic> tx) {
  _nav.pushReplacement(MaterialPageRoute(
    builder: (_) => SuccessScreen(
      tx: tx,
      onDone: () => _nav.popUntil((r) => r.isFirst),
    ),
  ));
}

void _gotoQR() {
  _nav.push(MaterialPageRoute(
    builder: (_) => QRScanScreen(api: _api, onDetected: _gotoMerchantPay),
  ));
}

void _gotoMerchantPay(Map<String, dynamic> m) {
  final merchant = {
    'name':       m['merchantName'] ?? m['name'] ?? 'Comerciante',
    'city':       m['merchantCity'] ?? m['city'] ?? '',
    'mcc':        m['mcc'] ?? '0000',
    'merchantId': m['merchantId'] ?? '',
    'dfspSwift':  m['dfspSwift'] ?? '',
    'amount':     m['amount'],
  };
  _nav.pushReplacement(MaterialPageRoute(
    builder: (_) => MerchantPayScreen(
      merchant: merchant,
      onPay: (tx) => _gotoConfirmP2M(tx, merchant),
    ),
  ));
}

void _gotoConfirmP2M(Map<String, dynamic> tx, Map<String, dynamic> merchant) {
  _nav.push(MaterialPageRoute(
    builder: (_) => ConfirmScreen(
      tx: {...tx, 'phone': merchant['city']},
      onConfirm: () async {
        final receipt = await _transfer.payMerchant(
          payerMsisdn: '2389001',
          merchantId: merchant['merchantId'] as String,
          amount: tx['amount'] as num,
        );
        final fee = num.tryParse(receipt['fee']?.toString() ?? '0') ?? 0;
        WalletService.instance.debit(tx['amount'] as num, fee);
        _gotoSuccess({...tx, ...receipt});
      },
    ),
  ));
}

// ── Splash ────────────────────────────────────────────────────────────────────

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
