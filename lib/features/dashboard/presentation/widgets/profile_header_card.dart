import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../orders/presentation/viewmodel/order_viewmodel.dart';
import '../../presentation/provider/wishlist_provider.dart';

class ProfileHeaderCard extends ConsumerWidget {
  final VoidCallback onAvatarTap;

  const ProfileHeaderCard({super.key, required this.onAvatarTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.name ?? 'Guest User';
    final userEmail = currentUser?.email ?? 'guest@tapto.com';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    final profileImageUrl = currentUser?.profilePicture;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar with Camera Icon
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(
                        ImageUtils.getImageUrl(profileImageUrl),
                      )
                    : null,
                child: profileImageUrl == null
                    ? Text(
                        userInitial,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            userName,
            style: AppTextStyles.subHeading.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stats Row - using real data from providers
          Builder(
            builder: (context) {
              final orderState = ref.watch(orderViewModelProvider);
              final wishlistCount = ref.watch(wishlistCountProvider);
              final ordersCount = orderState.orders.length;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    icon: Icons.shopping_bag_outlined,
                    count: '$ordersCount',
                    label: 'orders'.tr(),
                    onSurfaceColor: colorScheme.onSurface,
                  ),
                  const _VerticalDivider(),
                  _StatItem(
                    icon: Icons.favorite_outline,
                    count: '$wishlistCount',
                    label: 'wishlist'.tr(),
                    onSurfaceColor: colorScheme.onSurface,
                  ),
                  const _VerticalDivider(),
                  _StatItem(
                    icon: Icons.star_outline,
                    count: '4.8',
                    label: 'reviews'.tr(),
                    onSurfaceColor: colorScheme.onSurface,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color onSurfaceColor;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onSurfaceColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.8),
    );
  }
}
