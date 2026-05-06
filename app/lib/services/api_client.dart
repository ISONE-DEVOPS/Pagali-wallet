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
  }) => _post('$coreConnectorBase/transfers', {
    'transferId': transferId,
    'payer': {'idType': 'MSISDN', 'idValue': payerMsisdn, 'fspId': 'BCVCVCV'},
    'payee': {'idType': 'MSISDN', 'idValue': payeeMsisdn, 'fspId': 'CAIXACV'},
    'amount': amount.toString(),
    'currency': currency,
  });

  // 3) acceptQuote → execute
  Future<Map<String, dynamic>> executeTransfer({required String transferId, required bool accept}) =>
    _post('$coreConnectorBase/transfers/$transferId/accept-quote', {'accept': accept});

  // ─── Merchant registry (P2M) ───────────────────────────────────────────────
  Future<Map<String, dynamic>> getMerchant(String merchantId) =>
    _get('$merchantRegistryBase/merchants/$merchantId');

  // ─── QR service (EMVCo TLV parser) ─────────────────────────────────────────
  Future<Map<String, dynamic>> parseQr(String qrString) =>
    _post('$qrServiceBase/qr/parse', {'qrString': qrString});
}
