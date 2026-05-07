// lib/services/api_client.dart
// Thin HTTP client for the Pagali backend (core-connector + merchant-registry + qr-service).
// All hosts come from env via --dart-define so dev / staging / prod are swappable.

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int status;
  final String body;
  ApiException(this.status, this.body);
  @override
  String toString() => 'ApiException($status): $body';
}

class ApiClient {
  // Pass via:  flutter run --dart-define=CORE_CONNECTOR_BASE=https://...
  static const String coreConnectorBase = String.fromEnvironment(
    'CORE_CONNECTOR_BASE',
    defaultValue: 'http://localhost:8030',
  );
  static const String merchantRegistryBase = String.fromEnvironment(
    'MERCHANT_REGISTRY_BASE',
    defaultValue: 'http://localhost:4002',
  );
  static const String qrServiceBase = String.fromEnvironment(
    'QR_SERVICE_BASE',
    defaultValue: 'http://localhost:8031',
  );

  final http.Client _http;
  String? _bearer;
  ApiClient([http.Client? client]) : _http = client ?? http.Client();

  void setToken(String? token) => _bearer = token;

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_bearer != null) 'Authorization': 'Bearer $_bearer',
  };

  Future<Map<String, dynamic>> _get(String url) async {
    final r = await _http.get(Uri.parse(url), headers: _headers());
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
    final r = await _http.post(Uri.parse(url), headers: _headers(), body: jsonEncode(body));
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  // ─── Mojaloop 3-phase P2P (core-connector) ─────────────────────────────────
  // 1) discovery → returns transferId + receiver party
  Future<Map<String, dynamic>> discoverPayee({required String msisdn}) =>
    _get('$coreConnectorBase/parties/MSISDN/$msisdn');

  // 2) acceptParty → quote
  Future<Map<String, dynamic>> requestQuote({
    required String transferId,
    required String payerMsisdn,
    required String payeeMsisdn,
    required num amount,
    String currency = 'CVE',
    String kind = 'P2P',
  }) => _post('$coreConnectorBase/transfers', {
    'transferId': transferId,
    'payer': {'idType': 'MSISDN', 'idValue': payerMsisdn, 'fspId': 'BCVCVCV'},
    'payee': {'idType': kind == 'P2M' ? 'BUSINESS' : 'MSISDN', 'idValue': payeeMsisdn, 'fspId': 'BCNCV'},
    'amount': amount.toString(),
    'currency': currency,
    'kind': kind,
  });

  // 3) acceptQuote → execute
  Future<Map<String, dynamic>> executeTransfer({required String transferId, required bool accept}) =>
    _post('$coreConnectorBase/transfers/$transferId/accept-quote', {'accept': accept});

  // ─── Merchant registry (P2M) ───────────────────────────────────────────────
  Future<Map<String, dynamic>> getMerchant(String merchantId) =>
    _get('$merchantRegistryBase/merchants/$merchantId');

  Future<List<Map<String, dynamic>>> getMerchantPayments(String merchantId) async {
    final r = await _http.get(Uri.parse('$merchantRegistryBase/payments/$merchantId'), headers: _headers());
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  // ─── QR service (EMVCo TLV parser) ─────────────────────────────────────────
  Future<Map<String, dynamic>> parseQr(String qrString) =>
    _post('$qrServiceBase/qr/parse', {'qrString': qrString});

  // ─── Histórico ──────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getTransfers() async {
    final r = await _http.get(Uri.parse('$coreConnectorBase/transfers'), headers: _headers());
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  // ─── QR Generator ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> generateQR({
    required String merchantId,
    required String dfspSwift,
    required String merchantName,
    required String merchantCity,
    String? mcc,
    String? amount,
  }) => _post('$qrServiceBase/qr/generate', {
    'merchantId': merchantId,
    'dfspSwift': dfspSwift,
    'merchantName': merchantName,
    'merchantCity': merchantCity,
    if (mcc != null) 'mcc': mcc,
    if (amount != null) 'amount': amount,
  });

  // ─── G2P (Government-to-Person) ─────────────────────────────────────────────
  Future<Map<String, dynamic>> createG2PBatch({
    required String program,
    required List<Map<String, String>> beneficiaries,
    String? disbursedBy,
  }) => _post('$coreConnectorBase/g2p/batches', {
    'program': program,
    'disbursedBy': disbursedBy ?? 'Governo de Cabo Verde',
    'beneficiaries': beneficiaries,
  });

  Future<Map<String, dynamic>> getG2PBatch(String batchId) =>
    _get('$coreConnectorBase/g2p/batches/$batchId');

  // ─── FX (Cross-Currency) ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getFxQuote({
    required String sourceCurrency,
    required double sourceAmount,
    required String payeeMsisdn,
  }) => _post('$coreConnectorBase/fx/quote', {
    'sourceCurrency': sourceCurrency,
    'sourceAmount': sourceAmount,
    'payeeMsisdn': payeeMsisdn,
  });

  // ─── R2P (Request to Pay) ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> createR2P({
    required String merchantId,
    required String merchantName,
    required String payerMsisdn,
    required double amount,
    String? description,
  }) => _post('$coreConnectorBase/requests', {
    'merchantId': merchantId, 'merchantName': merchantName,
    'payerMsisdn': payerMsisdn, 'amount': amount,
    'description': description ?? 'Pedido de pagamento',
  });

  Future<List<Map<String, dynamic>>> getR2PForPayer(String msisdn) async {
    final r = await _http.get(Uri.parse('$coreConnectorBase/requests/payer/$msisdn'), headers: _headers());
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> acceptR2P(String requestId) =>
    _post('$coreConnectorBase/requests/$requestId/accept', {});

  Future<Map<String, dynamic>> rejectR2P(String requestId) =>
    _post('$coreConnectorBase/requests/$requestId/reject', {});

  // ─── Agent Banking ──────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAgents() async {
    final r = await _http.get(Uri.parse('$coreConnectorBase/agents'), headers: _headers());
    if (r.statusCode >= 400) throw ApiException(r.statusCode, r.body);
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getAgent(String agentId) =>
    _get('$coreConnectorBase/agents/$agentId');

  Future<Map<String, dynamic>> agentCashIn(String agentId, String customerMsisdn, double amount) =>
    _post('$coreConnectorBase/agents/$agentId/cash-in', {'customerMsisdn': customerMsisdn, 'amount': amount});

  Future<Map<String, dynamic>> agentCashOut(String agentId, String customerMsisdn, double amount) =>
    _post('$coreConnectorBase/agents/$agentId/cash-out', {'customerMsisdn': customerMsisdn, 'amount': amount});

  // ─── FX (Cross-Currency) ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> executeFxTransfer({
    required String sourceCurrency,
    required double sourceAmount,
    required double targetAmount,
    required double exchangeRate,
    required double fee,
    required String payeeMsisdn,
    String? payerMsisdn,
  }) => _post('$coreConnectorBase/fx/transfers', {
    'sourceCurrency': sourceCurrency,
    'sourceAmount': sourceAmount,
    'targetAmount': targetAmount,
    'exchangeRate': exchangeRate,
    'fee': fee,
    'payeeMsisdn': payeeMsisdn,
    'payerMsisdn': payerMsisdn ?? '2389001',
  });
}
