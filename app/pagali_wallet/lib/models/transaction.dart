// lib/models/transaction.dart
class TxParty {
  final String name;
  final String idValue; // MSISDN for P2P, merchantId for P2M
  final String? fspId;
  const TxParty({required this.name, required this.idValue, this.fspId});
}

enum TxKind { p2pIn, p2pOut, p2m, topup }

class Transaction {
  final TxKind kind;
  final TxParty counterparty;
  final num amount; // positive — sign comes from kind
  final String? note;
  final DateTime when;
  final String? id;
  const Transaction({
    required this.kind, required this.counterparty, required this.amount,
    this.note, required this.when, this.id,
  });

  bool get incoming => kind == TxKind.p2pIn || kind == TxKind.topup;
}
