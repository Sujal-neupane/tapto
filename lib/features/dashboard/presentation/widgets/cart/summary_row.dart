import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          isFree ? 'Free' : 'Rs. ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            color: isFree ? AppColors.success : AppColors.textPrimary,
            fontWeight: isFree ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}