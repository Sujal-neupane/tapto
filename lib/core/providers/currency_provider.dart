import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/auth/presentation/viewmodel/auth_viewmodel.dart';

/// Payment method info for a country
class PaymentMethodInfo {
  final String id;
  final String label;
  final IconData icon;

  const PaymentMethodInfo({
    required this.id,
    required this.label,
    required this.icon,
  });

  @override
  String toString() => label;
}

/// Currency information with exchange rate
class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final double rate; // Conversion rate FROM USD
  final String flag;
  final List<PaymentMethodInfo> paymentMethods;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rate,
    required this.flag,
    required this.paymentMethods,
  });

  @override
  String toString() => '$flag $symbol ($code)';
}

/// All supported countries → currency mapping
const Map<String, CurrencyInfo> countryCurrencyMap = {
  'united states': CurrencyInfo(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    rate: 1.0,
    flag: '🇺🇸',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'paypal',
        label: 'PayPal',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethodInfo(id: 'apple_pay', label: 'Apple Pay', icon: Icons.apple),
      PaymentMethodInfo(
        id: 'google_pay',
        label: 'Google Pay',
        icon: Icons.g_mobiledata,
      ),
      PaymentMethodInfo(
        id: 'cod',
        label: 'Cash on Delivery',
        icon: Icons.money,
      ),
    ],
  ),
  'united kingdom': CurrencyInfo(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    rate: 0.79,
    flag: '🇬🇧',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'paypal',
        label: 'PayPal',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethodInfo(id: 'apple_pay', label: 'Apple Pay', icon: Icons.apple),
      PaymentMethodInfo(
        id: 'google_pay',
        label: 'Google Pay',
        icon: Icons.g_mobiledata,
      ),
      PaymentMethodInfo(
        id: 'bank_transfer',
        label: 'Bank Transfer',
        icon: Icons.account_balance,
      ),
    ],
  ),
  'india': CurrencyInfo(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    rate: 83.50,
    flag: '🇮🇳',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'upi',
        label: 'UPI (GPay / PhonePe)',
        icon: Icons.phone_android,
      ),
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'net_banking',
        label: 'Net Banking',
        icon: Icons.account_balance,
      ),
      PaymentMethodInfo(
        id: 'wallet',
        label: 'Paytm Wallet',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethodInfo(
        id: 'cod',
        label: 'Cash on Delivery',
        icon: Icons.money,
      ),
    ],
  ),
  'nepal': CurrencyInfo(
    code: 'NPR',
    symbol: 'Rs',
    name: 'Nepalese Rupee',
    rate: 133.50,
    flag: '🇳🇵',
    paymentMethods: [
      PaymentMethodInfo(id: 'esewa', label: 'eSewa', icon: Icons.phone_android),
      PaymentMethodInfo(id: 'khalti', label: 'Khalti', icon: Icons.smartphone),
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'bank_transfer',
        label: 'Bank Transfer',
        icon: Icons.account_balance,
      ),
      PaymentMethodInfo(
        id: 'cod',
        label: 'Cash on Delivery',
        icon: Icons.money,
      ),
    ],
  ),
  'china': CurrencyInfo(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
    rate: 7.24,
    flag: '🇨🇳',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'wechat_pay',
        label: 'WeChat Pay',
        icon: Icons.chat,
      ),
      PaymentMethodInfo(
        id: 'alipay',
        label: 'Alipay',
        icon: Icons.phone_android,
      ),
      PaymentMethodInfo(
        id: 'card',
        label: 'UnionPay Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'cod',
        label: 'Cash on Delivery',
        icon: Icons.money,
      ),
    ],
  ),
  'japan': CurrencyInfo(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    rate: 149.50,
    flag: '🇯🇵',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'konbini',
        label: 'Konbini (Conv. Store)',
        icon: Icons.store,
      ),
      PaymentMethodInfo(
        id: 'paypay',
        label: 'PayPay',
        icon: Icons.phone_android,
      ),
      PaymentMethodInfo(
        id: 'bank_transfer',
        label: 'Bank Transfer',
        icon: Icons.account_balance,
      ),
      PaymentMethodInfo(
        id: 'cod',
        label: 'Cash on Delivery',
        icon: Icons.money,
      ),
    ],
  ),
  'south korea': CurrencyInfo(
    code: 'KRW',
    symbol: '₩',
    name: 'South Korean Won',
    rate: 1320.0,
    flag: '🇰🇷',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'kakao_pay',
        label: 'Kakao Pay',
        icon: Icons.phone_android,
      ),
      PaymentMethodInfo(
        id: 'naver_pay',
        label: 'Naver Pay',
        icon: Icons.smartphone,
      ),
      PaymentMethodInfo(
        id: 'bank_transfer',
        label: 'Bank Transfer',
        icon: Icons.account_balance,
      ),
      PaymentMethodInfo(
        id: 'cod',
        label: 'Cash on Delivery',
        icon: Icons.money,
      ),
    ],
  ),
  'australia': CurrencyInfo(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
    rate: 1.54,
    flag: '🇦🇺',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'paypal',
        label: 'PayPal',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethodInfo(
        id: 'afterpay',
        label: 'Afterpay',
        icon: Icons.schedule,
      ),
      PaymentMethodInfo(id: 'apple_pay', label: 'Apple Pay', icon: Icons.apple),
      PaymentMethodInfo(
        id: 'bank_transfer',
        label: 'Bank Transfer',
        icon: Icons.account_balance,
      ),
    ],
  ),
  'germany': CurrencyInfo(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    rate: 0.92,
    flag: '🇩🇪',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'card',
        label: 'Credit/Debit Card',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'paypal',
        label: 'PayPal',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethodInfo(
        id: 'sofort',
        label: 'Sofort / Klarna',
        icon: Icons.payment,
      ),
      PaymentMethodInfo(
        id: 'sepa',
        label: 'SEPA Direct Debit',
        icon: Icons.account_balance,
      ),
      PaymentMethodInfo(
        id: 'google_pay',
        label: 'Google Pay',
        icon: Icons.g_mobiledata,
      ),
    ],
  ),
  'france': CurrencyInfo(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    rate: 0.92,
    flag: '🇫🇷',
    paymentMethods: [
      PaymentMethodInfo(
        id: 'card',
        label: 'Carte Bancaire',
        icon: Icons.credit_card,
      ),
      PaymentMethodInfo(
        id: 'paypal',
        label: 'PayPal',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethodInfo(id: 'apple_pay', label: 'Apple Pay', icon: Icons.apple),
      PaymentMethodInfo(
        id: 'sepa',
        label: 'SEPA Direct Debit',
        icon: Icons.account_balance,
      ),
      PaymentMethodInfo(
        id: 'cod',
        label: 'Cash on Delivery',
        icon: Icons.money,
      ),
    ],
  ),
};

/// Default USD currency
const CurrencyInfo defaultCurrency = CurrencyInfo(
  code: 'USD',
  symbol: '\$',
  name: 'US Dollar',
  rate: 1.0,
  flag: '🇺🇸',
  paymentMethods: [
    PaymentMethodInfo(
      id: 'card',
      label: 'Credit/Debit Card',
      icon: Icons.credit_card,
    ),
    PaymentMethodInfo(
      id: 'paypal',
      label: 'PayPal',
      icon: Icons.account_balance_wallet,
    ),
    PaymentMethodInfo(id: 'cod', label: 'Cash on Delivery', icon: Icons.money),
  ],
);

/// Helper to resolve country string → CurrencyInfo
CurrencyInfo _getCurrencyForCountry(String? country) {
  if (country == null || country.isEmpty) return defaultCurrency;
  return countryCurrencyMap[country.toLowerCase()] ?? defaultCurrency;
}

/// Helper to resolve currency code → CurrencyInfo
CurrencyInfo _getCurrencyForCode(String? code) {
  if (code == null || code.isEmpty) return defaultCurrency;
  for (final entry in countryCurrencyMap.entries) {
    if (entry.value.code.toLowerCase() == code.toLowerCase()) {
      return entry.value;
    }
  }
  return defaultCurrency;
}

/// Currency provider based on user's selected country from auth state or stored locally
final currencyProvider = Provider<CurrencyInfo>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final authState = ref.watch(authViewModelProvider);
  final user = authState.user;

  // Prefer locally stored country from registration for consistent currency.
  String? country = hiveService.get<String>('user_country');
  if (country == null || country.isEmpty) {
    country = user?.country;
  }

  if (country == null || country.isEmpty) {
    country = 'Nepal';
  }

  return _getCurrencyForCountry(country);
});

/// Base currency used for stored product prices.
/// Default is NPR to keep prices consistent with local catalog values.
final baseCurrencyProvider = Provider<CurrencyInfo>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final baseCode = hiveService.get<String>(
    'base_currency',
    defaultValue: 'NPR',
  );

  return _getCurrencyForCode(baseCode);
});

/// Tax rate provider based on user's selected country
final taxRateProvider = Provider<double>((ref) {
  final authState = ref.watch(authViewModelProvider);
  final user = authState.user;

  String? country = user?.country;
  if (country == null || country.isEmpty) {
    final hiveService = ref.watch(hiveServiceProvider);
    country = hiveService.get<String>('user_country', defaultValue: 'Nepal');
  }

  switch (country?.toLowerCase()) {
    case 'united states':
      return 0.08; // 8% sales tax
    case 'united kingdom':
      return 0.20; // 20% VAT
    case 'india':
      return 0.18; // 18% GST
    case 'nepal':
      return 0.13; // 13% VAT
    case 'china':
      return 0.13; // 13% VAT
    case 'japan':
      return 0.10; // 10% consumption tax
    case 'south korea':
      return 0.10; // 10% VAT
    case 'australia':
      return 0.10; // 10% GST
    case 'germany':
    case 'france':
      return 0.19; // 19% MwSt / TVA
    default:
      return 0.08;
  }
});

/// Payment methods provider based on user's country
final paymentMethodsProvider = Provider<List<PaymentMethodInfo>>((ref) {
  final currency = ref.watch(currencyProvider);
  return currency.paymentMethods;
});
