import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';
import '../../../../app/widgets/logout_dialog.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../auth/presentation/state/auth_state.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _emailUpdates = true;
  String _selectedLanguage = 'English';

  void _handleLogout(BuildContext context) async {
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
  Widget build(BuildContext context) {
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
        title: 'Settings',
        subtitle: "Manage your app preferences",
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile feature coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password feature coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            const SizedBox(height: AppSpacing.sm),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive app notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSwitchTile(
              icon: Icons.email_outlined,
              title: 'Email Updates',
              subtitle: 'Receive updates via email',
              value: _emailUpdates,
              onChanged: (value) {
                setState(() {
                  _emailUpdates = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Appearance Section
            _buildSectionHeader('Appearance'),
            const SizedBox(height: AppSpacing.sm),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () {
                _showLanguageDialog();
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Support Section
            _buildSectionHeader('Support'),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Get help and support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help center coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {
                _showAboutDialog();
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.rate_review_outlined,
              title: 'Rate App',
              subtitle: 'Share your feedback',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your interest!'),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Legal Section
            _buildSectionHeader('Legal'),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy policy coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'View terms and conditions',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of service coming soon!'),
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
                onPressed: () => _handleLogout(context),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        secondary: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
            _buildLanguageOption('Nepali'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        Navigator.pop(context);
      },
      activeColor: AppColors.primary,
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'TapTo',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.shopping_bag,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text('A complete solution for your shopping needs.'),
      ],
    );
  }
}