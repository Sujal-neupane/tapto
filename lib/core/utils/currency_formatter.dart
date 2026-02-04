import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/providers/currency_provider.dart';

/// Currency formatting utility
class CurrencyFormatter {
  static String format(double amount, CurrencyInfo currency) {
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }
}

/// Provider for formatted currency
final currencyFormatterProvider = Provider<String Function(double)>((ref) {
  final currency = ref.watch(currencyProvider);
  return (amount) => CurrencyFormatter.format(amount, currency);
});