import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/providers/currency_provider.dart';

/// Currency formatting utility with exchange rate conversion.
///
/// Prices are stored in a base currency and converted to the user's currency.
class CurrencyFormatter {
  /// Convert a base amount to the target currency.
  static double convert(double amountBase, CurrencyInfo target, CurrencyInfo base) {
    if (target.code == base.code) return amountBase;
    return amountBase * (target.rate / base.rate);
  }

  /// Format a number for a currency, handling rounding rules.
  static String _formatAmount(double amount, CurrencyInfo currency) {
    // JPY and KRW don't use decimal places
    if (currency.code == 'JPY' || currency.code == 'KRW') {
      return '${currency.symbol}${amount.round()}';
    }

    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }

  /// Convert a base amount to the target currency and format it.
  /// If showBase is true and currencies differ, append the base amount.
  static String format(
    double amountBase,
    CurrencyInfo target,
    CurrencyInfo base, {
    bool showBase = false,
  }) {
    final converted = convert(amountBase, target, base);
    final convertedText = _formatAmount(converted, target);

    if (!showBase || target.code == base.code) {
      return convertedText;
    }

    final baseText = _formatAmount(amountBase, base);
    return '$convertedText ($baseText ${base.code})';
  }
}

/// Provider for formatted currency – returns a closure: (double usdPrice) → "Rs17,800.00"
final currencyFormatterProvider = Provider<String Function(double)>((ref) {
  final currency = ref.watch(currencyProvider);
  final baseCurrency = ref.watch(baseCurrencyProvider);
  return (amount) => CurrencyFormatter.format(amount, currency, baseCurrency);
});
