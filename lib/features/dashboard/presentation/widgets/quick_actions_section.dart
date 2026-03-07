import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class QuickActionsSection extends ConsumerWidget {
  final VoidCallback onTrackOrderTap;

  const QuickActionsSection({super.key, required this.onTrackOrderTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Quick Actions Section
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'support'.tr(),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.shopping_bag_outlined,
                title: 'myOrders'.tr(),
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.myOrders);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.favorite_outline,
                title: 'wishlist'.tr(),
                color: Colors.red,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.wishlist);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.local_shipping_outlined,
                title: 'trackOrder'.tr(),
                color: Colors.orange,
                onTap: onTrackOrderTap,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt_long_outlined,
                title: 'orders'.tr(),
                color: Colors.green,
                onTap: () {
                  // Navigate to orders screen where invoices can be downloaded
                  Navigator.pushNamed(context, AppRoutes.myOrders);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('orderDetails'.tr()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: colorScheme.brightness == Brightness.dark ? 0.2 : 0.1,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(
                alpha: colorScheme.brightness == Brightness.dark ? 0.45 : 0.3,
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: colorScheme.brightness == Brightness.dark
                        ? 0.28
                        : 0.2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
