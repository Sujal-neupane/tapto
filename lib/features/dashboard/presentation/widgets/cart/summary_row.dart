import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/utils/currency_formatter.dart';

class SummaryRow extends ConsumerWidget {
  final String label;
  final double value;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFree = value == 0;
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormatter = ref.watch(currencyFormatterProvider);
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
          isFree ? 'Free' : currencyFormatter(value),
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
