// lib/utils/format.dart
import 'package:intl/intl.dart';

class Money {
  // Cape Verdean Escudo formatting: 1.234,56
  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'pt_CV', symbol: '', decimalDigits: 2,
  );
  static String cve(num value) => _fmt.format(value).trim();
}
