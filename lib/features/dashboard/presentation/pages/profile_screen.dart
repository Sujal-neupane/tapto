import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';
import '../../../../app/widgets/logout_dialog.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../auth/presentation/state/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => LogoutDialog(
        onConfirm: () async {
          await ref.read(authViewModelProvider.notifier).logout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.name ?? 'Guest User';
    final userEmail = currentUser?.email ?? 'guest@tapto.com';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';

    // Listen for logout completion
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.loggedOut && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'My Profile',
        subtitle: userEmail,
        showLogo: false,
        showBackButton: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.getMaxContentWidth(context),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            userInitial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          userName,
                          style: AppTextStyles.subHeading.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Menu Items
                  _ProfileMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    subtitle: 'Track your orders',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orders feature coming soon!'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProfileMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Wishlist',
                    subtitle: 'Your favorite items',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wishlist feature coming soon!'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                    subtitle: 'Manage your addresses',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Addresses feature coming soon!'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings feature coming soon!'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get assistance',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support feature coming soon!'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context, ref),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
