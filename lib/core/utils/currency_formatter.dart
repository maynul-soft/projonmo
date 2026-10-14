import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,##0.##', 'en_US');

  /// Formats amount into standard BDT currency string, e.g. "৳ 12,500"
  static String format(num? amount, {bool showSymbol = true}) {
    if (amount == null) return showSymbol ? '${AppStrings.currencySymbol} 0' : '0';
    final formatted = _formatter.format(amount);
    return showSymbol ? '${AppStrings.currencySymbol} $formatted' : formatted;
  }
}
