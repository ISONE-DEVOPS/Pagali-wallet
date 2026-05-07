// lib/utils/validators.dart — Validações reutilizáveis Pagali

class Validators {
  // MSISDN Cabo Verde: 7 dígitos após remover +238 e espaços
  static String? msisdn(String value, {String? ownMsisdn}) {
    final digits = value.replaceAll(RegExp(r'[\s\+\-]'), '').replaceFirst('238', '');
    if (digits.isEmpty) return 'Insira um número de telemóvel';
    if (!RegExp(r'^\d{7}$').hasMatch(digits)) return 'Número inválido — deve ter 7 dígitos (ex: 9381234)';
    if (ownMsisdn != null && digits == ownMsisdn.replaceFirst('238', '')) {
      return 'Não pode enviar para si próprio';
    }
    return null;
  }

  // Montante: deve ser número positivo dentro de limites
  static String? amount(String value, {num min = 1, num? max, num? available}) {
    final n = num.tryParse(value);
    if (n == null || n <= 0) return 'Insira um montante válido';
    if (n < min) return 'Montante mínimo: $min CVE';
    if (max != null && n > max) return 'Montante máximo: $max CVE';
    if (available != null && n > available) return 'Saldo insuficiente (${available.toStringAsFixed(2)} CVE disponível)';
    return null;
  }

  // NIF Cabo Verde: letras + dígitos, 6-12 caracteres
  static String? nif(String value) {
    final v = value.trim().toUpperCase();
    if (v.isEmpty) return 'Insira o NIF';
    if (v.length < 6) return 'NIF inválido — mínimo 6 caracteres';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(v)) return 'NIF inválido — apenas letras e números';
    return null;
  }

  // Período: MM/AAAA
  static String? period(String value) {
    if (!RegExp(r'^\d{2}/\d{4}$').hasMatch(value)) return 'Formato inválido — use MM/AAAA (ex: 05/2026)';
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    if (month < 1 || month > 12) return 'Mês inválido (01–12)';
    return null;
  }

  // FX: limites por moeda
  static final _fxLimits = {
    'EUR': (min: 1.0, max: 5000.0),
    'USD': (min: 1.0, max: 5000.0),
    'GBP': (min: 1.0, max: 5000.0),
    'BRL': (min: 5.0, max: 10000.0),
  };

  static String? fxAmount(String value, String currency) {
    final n = double.tryParse(value);
    if (n == null || n <= 0) return 'Insira um montante válido';
    final limits = _fxLimits[currency];
    if (limits == null) return null;
    if (n < limits.min) return 'Mínimo: ${limits.min} $currency';
    if (n > limits.max) return 'Máximo: ${limits.max} $currency';
    return null;
  }
}
