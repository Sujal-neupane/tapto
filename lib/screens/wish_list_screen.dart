import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Wishlist", style: text.titleMedium),
        centerTitle: true,
      ),
      body: const _EmptyWishlistView(),
    );
  }
}

class _EmptyWishlistView extends StatelessWidget {
  const _EmptyWishlistView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: colors.surfaceContainerHigh.withOpacity(0.3),
                child: Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: colors.outline,
                ),
              ),
              const SizedBox(height: 24),
              Text("Your wishlist is empty", style: text.titleLarge),
              const SizedBox(height: 8),
              Text(
                "Double-tap on products you like to add them here.",
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: colors.outline),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  // Navigate to swipe home
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text("Start Shopping"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
