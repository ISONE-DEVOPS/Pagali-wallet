import 'package:flutter/foundation.dart';

class InsufficientBalanceException implements Exception {
  final num required;
  final num available;
  InsufficientBalanceException(this.required, this.available);
  @override
  String toString() => 'Saldo insuficiente. Necessário: ${required.toStringAsFixed(2)} CVE · Disponível: ${available.toStringAsFixed(2)} CVE';
}

class WalletService {
  static final WalletService instance = WalletService._();
  WalletService._();

  final ValueNotifier<num> balance = ValueNotifier(5320);

  bool canDebit(num amount, num fee) => balance.value >= amount + fee;

  void debit(num amount, num fee) {
    final total = amount + fee;
    if (!canDebit(amount, fee)) {
      throw InsufficientBalanceException(total, balance.value);
    }
    balance.value = balance.value - total;
  }

  void credit(num amount) {
    balance.value = balance.value + amount;
  }
}
