import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../addresses/presentation/pages/addresses_screen.dart';
import '../../presentation/pages/edit_profile_screen.dart';

class AccountSection extends StatelessWidget {
  final VoidCallback onPaymentMethodsTap;

  const AccountSection({super.key, required this.onPaymentMethodsTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Account Section
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'account'.tr(),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        _ProfileMenuItem(
          icon: Icons.person_outline,
          title: 'editProfile'.tr(),
          subtitle: 'updatePersonalInfo'.tr(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileMenuItem(
          icon: Icons.location_on_outlined,
          title: 'address'.tr(),
          subtitle: 'deliveryAddress'.tr(),
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
          title: 'paymentMethod'.tr(),
          subtitle: 'paymentMethod'.tr(),
          onTap: onPaymentMethodsTap,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileMenuItem(
          icon: Icons.settings_outlined,
          title: 'settings'.tr(),
          subtitle: 'managePreferences'.tr(),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
