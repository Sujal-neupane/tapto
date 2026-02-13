import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/routes/app_routes.dart';
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
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: cartState.items.isEmpty
            ? Column(
                children: [
                  CartAppBar(itemCount: 0),
                  const Expanded(child: EmptyCart()),
                ],
              )
            : Column(
                children: [
                  CartAppBar(itemCount: cartState.items.length),
                  const Expanded(child: CartBody()),
                  CheckoutPanel(
                    onCheckout: () {
                      Navigator.pushNamed(context, AppRoutes.checkOut);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
