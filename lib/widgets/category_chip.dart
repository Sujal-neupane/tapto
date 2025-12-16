import 'package:flutter/material.dart';

class TaptoCategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TaptoCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            // style: AppTypography.body.copyWith(
            // fontWeight: FontWeight.w600,
            // color: selected ? Colors.white : colors.primary,
            // ),
          ),
        ),
      ),
    );
  }
}
