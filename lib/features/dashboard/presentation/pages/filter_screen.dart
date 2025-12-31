import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.lg),

          Text('Price Range', style: AppTextStyles.subHeading),
          const SizedBox(height: AppSpacing.sm),
          RangeSlider(
            values: const RangeValues(20, 200),
            min: 0,
            max: 500,
            onChanged: (_) {},
          ),

          const SizedBox(height: AppSpacing.lg),
          Text('Category', style: AppTextStyles.subHeading),
          const SizedBox(height: AppSpacing.sm),

          Wrap(
            spacing: AppSpacing.sm,
            children: const [
              Chip(label: Text('Shoes')),
              Chip(label: Text('Clothing')),
              Chip(label: Text('Accessories')),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
