import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/timer_widget.dart';
import '../../../../core/utils/responsive_utils.dart';

class HomeSwipeScreen extends StatelessWidget {
  const HomeSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          // Time Tracking Section
          const TimerWidget(isRunning: true),
          const SizedBox(height: AppSpacing.lg),

          // Recent Sessions
          Container(
            padding: EdgeInsets.all(isTablet ? AppSpacing.lg : AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Activities',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            14,
                          ),
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '4 sessions • 2h 45m',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            12,
                          ),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Swipeable Products Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discover Products',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Swipe to explore',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Product Cards
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(
                    5,
                    (index) => Draggable(
                      childWhenDragging: const SizedBox.shrink(),
                      feedback: _ProductCard(index: index),
                      child: _ProductCard(index: index),
                      onDragEnd: (details) {
                        // Swipe logic here
                      },
                    ),
                  ).reversed.toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;
  const _ProductCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveUtils.getCardWidth(context);
    final cardHeight = ResponsiveUtils.getCardHeight(context);
    final isTablet =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    return Card(
      elevation: isTablet ? 12 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
      ),
      margin: EdgeInsets.all(isTablet ? AppSpacing.lg : AppSpacing.md),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isTablet ? 32 : 24),
                  ),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 100),
                  color: AppColors.primary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? AppSpacing.xl : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product ${index + 1}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        18,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '\$${(99.99 + (index * 10)).toStringAsFixed(2)}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
