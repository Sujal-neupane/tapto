import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/routes/app_routes.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';
import '../widgets/cart/cart_app_bar.dart';
import '../widgets/cart/cart_body.dart';
import '../widgets/cart/checkout_panel.dart';
import '../widgets/cart/empty_cart.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartViewModelProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _buildBody(context, cartState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartState cartState) {
    final colorScheme = Theme.of(context).colorScheme;

    // Show loading state
    if (cartState.isLoading && cartState.items.isEmpty) {
      return Column(
        children: [
          CartAppBar(itemCount: 0),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      );
    }

    // Show error state
    if (cartState.error != null && cartState.items.isEmpty) {
      return Column(
        children: [
          CartAppBar(itemCount: 0),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 60,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error loading cart',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      cartState.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(cartViewModelProvider.notifier).loadCart();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Show empty cart
    if (cartState.items.isEmpty) {
      return Column(
        children: [
          CartAppBar(itemCount: 0),
          const Expanded(child: EmptyCart()),
        ],
      );
    }

    // Show cart with items
    return Column(
      children: [
        CartAppBar(itemCount: cartState.items.length),
        Expanded(child: CartBody()),
        CheckoutPanel(
          onCheckout: () {
            Navigator.pushNamed(context, AppRoutes.checkOut);
          },
        ),
      ],
    );
  }
}
