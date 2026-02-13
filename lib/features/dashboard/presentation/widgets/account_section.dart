import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../addresses/presentation/pages/addresses_screen.dart';
import '../../presentation/pages/edit_profile_screen.dart';

class AccountSection extends StatelessWidget {
  final VoidCallback onPaymentMethodsTap;

  const AccountSection({
    super.key,
    required this.onPaymentMethodsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Account Section
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Account',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        _ProfileMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileMenuItem(
          icon: Icons.location_on_outlined,
          title: 'Addresses',
          subtitle: 'Manage delivery addresses',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressesScreen()),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileMenuItem(
          icon: Icons.payment_outlined,
          title: 'Payment Methods',
          subtitle: 'Manage your payment options',
          onTap: onPaymentMethodsTap,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileMenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'App preferences and account settings',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.setting);
          },
        ),
      ],
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