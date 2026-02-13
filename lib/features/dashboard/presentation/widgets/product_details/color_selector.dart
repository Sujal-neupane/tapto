import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';

class ColorSelector extends StatefulWidget {
  final List<String> colors;
  final String? selectedColor;
  final ValueChanged<String?> onColorSelected;

  const ColorSelector({
    super.key,
    required this.colors,
    this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
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
              'SELECT COLOR',
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
                (constraints.maxWidth -
                    (spacing * (widget.colors.length - 1))) /
                widget.colors.length;

            return Wrap(
              spacing: spacing,
              runSpacing: 12,
              children: widget.colors.map((color) {
                final isSelected = widget.selectedColor == color;
                return InkWell(
                  onTap: () {
                    widget.onColorSelected(color);
                  },
                  borderRadius: BorderRadius.circular(12),
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
                      color,
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