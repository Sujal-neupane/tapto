import 'package:flutter/material.dart';

class CartChip extends StatelessWidget {
  final String text;

  const CartChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.75),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
