import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/providers/currency_provider.dart';

/// Currency formatting utility with exchange rate conversion.
///
/// All product prices in the backend are stored in USD.
/// This class converts USD → user's local currency and formats the result.
class CurrencyFormatter {
  /// Convert a USD amount to the target currency and format it.
  static String format(double amountUSD, CurrencyInfo currency) {
    final converted = amountUSD * currency.rate;

    // JPY and KRW don't use decimal places
    if (currency.code == 'JPY' || currency.code == 'KRW') {
      return '${currency.symbol}${converted.round()}';
    }

    return '${currency.symbol}${converted.toStringAsFixed(2)}';
  }

  /// Just convert without formatting (for calculations).
  static double convert(double amountUSD, CurrencyInfo currency) {
    return amountUSD * currency.rate;
  }
}

/// Provider for formatted currency – returns a closure: (double usdPrice) → "Rs17,800.00"
final currencyFormatterProvider = Provider<String Function(double)>((ref) {
  final currency = ref.watch(currencyProvider);
  return (amount) => CurrencyFormatter.format(amount, currency);
});
