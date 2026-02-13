import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/core/providers/currency_provider.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';

class CheckoutBottomBar extends ConsumerWidget {
  final List<CartItemModel> cartItems;
  final double cartTotal;
  final bool isPlacingOrder;
  final VoidCallback onPlaceOrder;

  const CheckoutBottomBar({
    super.key,
    required this.cartItems,
    required this.cartTotal,
    required this.isPlacingOrder,
    required this.onPlaceOrder,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isPlacingOrder ? null : onPlaceOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: isPlacingOrder
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Place Order',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• ${currencyFormatter(total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}