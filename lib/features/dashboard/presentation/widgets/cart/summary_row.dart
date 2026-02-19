import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = value == 0;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          isFree ? 'Free' : 'Rs. ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            color: isFree ? Colors.green : colorScheme.onSurface,
            fontWeight: isFree ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
