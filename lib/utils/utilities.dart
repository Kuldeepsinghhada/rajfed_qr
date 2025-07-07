

import 'package:intl/intl.dart';

class Utilities {
  static String formatIndianNumber(num value) {
    final isInteger = value == value.roundToDouble();
    final formatter = NumberFormat.decimalPattern('en_IN');
    return isInteger
        ? formatter.format(value)
        : NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 2,
    ).format(value).trim();
  }
}