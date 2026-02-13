import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/core/providers/currency_provider.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';

class OrderDetailsCard extends ConsumerWidget {
  final List<CartItemModel> cartItems;

  const OrderDetailsCard({
    super.key,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final shipping = cartItems.isEmpty ? 0.0 : 10.0;
    final taxRate = ref.watch(taxRateProvider);
    final tax = subtotal * taxRate;
    final total = subtotal + shipping + tax;
    final currencyFormatter = ref.watch(currencyFormatterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', subtotal, currencyFormatter),
          const SizedBox(height: 12),
          _buildPriceRow('Shipping', shipping, currencyFormatter,
              isFree: shipping == 0),
          const SizedBox(height: 12),
          _buildPriceRow('Tax', tax, currencyFormatter),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                currencyFormatter(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      String Function(double) currencyFormatter,
      {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        isFree
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              )
            : Text(
                currencyFormatter(amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
      ],
    );
  }
}