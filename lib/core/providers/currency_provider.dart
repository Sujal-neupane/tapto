import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/auth/presentation/viewmodel/auth_viewmodel.dart';

/// Currency information
class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });

  @override
  String toString() => '$symbol ($code)';
}

/// Currency provider based on user's selected country from auth state or stored locally
final currencyProvider = Provider<CurrencyInfo>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final user = authState.user;

  // First try to get country from authenticated user
  String? country = user?.country;

  // If not available, fallback to stored value
  if (country == null || country.isEmpty) {
    final hiveService = ref.watch(hiveServiceProvider);
    country = hiveService.get<String>('user_country', defaultValue: 'Nepal'); // Default to Nepal for existing users
  }

  switch (country?.toLowerCase()) {
    case 'united states':
      return const CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar');
    case 'india':
      return const CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee');
    case 'nepal':
      return const CurrencyInfo(code: 'NPR', symbol: '₨', name: 'Nepalese Rupee');
    default:
      return const CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar');
  }
});

/// Tax rate provider based on user's selected country from auth state or stored locally
final taxRateProvider = Provider<double>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final user = authState.user;

  // First try to get country from authenticated user
  String? country = user?.country;

  // If not available, fallback to stored value
  if (country == null || country.isEmpty) {
    final hiveService = ref.watch(hiveServiceProvider);
    country = hiveService.get<String>('user_country', defaultValue: 'Nepal'); // Default to Nepal for existing users
  }

  switch (country?.toLowerCase()) {
    case 'united states':
      return 0.08; // 8% tax
    case 'india':
      return 0.18; // 18% GST
    case 'nepal':
      return 0.13; // 13% VAT
    default:
      return 0.08; // Default 8%
  }
});

/// Payment methods provider based on user's selected country from auth state or stored locally
final paymentMethodsProvider = Provider<List<String>>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final user = authState.user;

  // First try to get country from authenticated user
  String? country = user?.country;

  // If not available, fallback to stored value
  if (country == null || country.isEmpty) {
    final hiveService = ref.watch(hiveServiceProvider);
    country = hiveService.get<String>('user_country', defaultValue: 'Nepal'); // Default to Nepal for existing users
  }

  switch (country?.toLowerCase()) {
    case 'united states':
      return ['Credit Card', 'Debit Card', 'PayPal', 'Apple Pay', 'Google Pay'];
    case 'india':
      return ['Credit Card', 'Debit Card', 'UPI', 'Paytm', 'PhonePe', 'Google Pay'];
    case 'nepal':
      return ['Credit Card', 'Debit Card', 'eSewa', 'Khalti', 'IME Pay', 'Bank Transfer'];
    default:
      return ['Credit Card', 'Debit Card', 'PayPal'];
  }
});