import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';

class SizeSelector extends StatefulWidget {
  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String?> onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SELECT SIZE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF212529),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate item width based on available width
            final spacing = 12.0;
            final itemWidth =
                (constraints.maxWidth - (spacing * (widget.sizes.length - 1))) /
                widget.sizes.length;

            return Wrap(
              spacing: spacing,
              runSpacing: 12,
              children: widget.sizes.map((size) {
                final isSelected = widget.selectedSize == size;
                return GestureDetector(
                  onTap: () => widget.onSizeSelected(size),
                  child: Container(
                    width: itemWidth.clamp(60.0, 100.0), // Min 60, Max 100
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFE9ECEF),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      size,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF495057),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}