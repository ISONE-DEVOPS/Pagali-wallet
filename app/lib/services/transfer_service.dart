// lib/services/transfer_service.dart
// Orchestrates the 3-phase Mojaloop P2P flow + the P2M merchant payment.
// UI calls these high-level methods so the screens never see raw transfer ids.

import 'package:uuid/uuid.dart';
import 'api_client.dart';

class TransferService {
  final ApiClient _api;
  final _uuid = const Uuid();
  TransferService(this._api);

  /// P2P: discover → quote → execute, returns final receipt map.
  Future<Map<String, dynamic>> sendP2P({
    required String payerMsisdn,
    required String payeeMsisdn,
    required num amount,
    String? note,
  }) async {
    final transferId = _uuid.v4();
    await _api.discoverPayee(msisdn: payeeMsisdn);
    final quote = await _api.requestQuote(
      transferId: transferId,
      payerMsisdn: payerMsisdn, payeeMsisdn: payeeMsisdn,
      amount: amount,
    );
    final execution = await _api.executeTransfer(transferId: transferId, accept: true);
    return {
      'transferId': transferId,
      'fee': quote['fee'] ?? 0,
      'state': execution['state'] ?? 'COMMITTED',
      'note': note,
    };
  }

  /// P2M: lookup merchant by id, then settle via the same transfer rail.
  Future<Map<String, dynamic>> payMerchant({
    required String payerMsisdn,
    required String merchantId,
    required num amount,
  }) async {
    final m = await _api.getMerchant(merchantId);
    final transferId = _uuid.v4();
    final quote = await _api.requestQuote(
      transferId: transferId,
      payerMsisdn: payerMsisdn,
      payeeMsisdn: m['msisdn'] ?? merchantId,
      amount: amount,
    );
    final execution = await _api.executeTransfer(transferId: transferId, accept: true);
    return {
      'transferId': transferId,
      'merchant': m,
      'fee': quote['fee'] ?? 0,
      'state': execution['state'] ?? 'COMMITTED',
    };
  }
}
