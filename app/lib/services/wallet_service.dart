// lib/services/wallet_service.dart
// Saldo em memória — notifica a UI quando muda.

import 'package:flutter/foundation.dart';

class WalletService {
  static final WalletService instance = WalletService._();
  WalletService._();

  final ValueNotifier<num> balance = ValueNotifier(5320);

  void debit(num amount, num fee) {
    balance.value = balance.value - amount - fee;
  }

  void credit(num amount) {
    balance.value = balance.value + amount;
  }
}
