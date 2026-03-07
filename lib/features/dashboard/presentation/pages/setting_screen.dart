import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tapto/features/dashboard/presentation/pages/help_center_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/privacy_policy_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/edit_profile_screen.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';
import '../../../../app/widgets/logout_dialog.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/providers/theme_provider.dart'; // <-- ADDED: Notification service
import 'terms_of_service_screen.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  String _selectedLanguageCode = 'en';
  bool _didInitLocale = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitLocale) {
      _selectedLanguageCode = context.locale.languageCode;
      _didInitLocale = true;
    }
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'english'.tr();
      case 'es':
        return 'spanish'.tr();
      case 'fr':
        return 'french'.tr();
      case 'de':
        return 'german'.tr();
      case 'ne':
        return 'nepali'.tr();
      default:
        return 'english'.tr();
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);
    await context.setLocale(locale);

    // Update language provider
    final appLanguage = _getAppLanguageFromCode(languageCode);
    ref.read(languageProvider.notifier).setLanguage(appLanguage);

    setState(() {
      _selectedLanguageCode = languageCode;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('languageChanged'.tr()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  AppLanguage _getAppLanguageFromCode(String code) {
    switch (code) {
      case 'en':
        return AppLanguage.english;
      case 'es':
        return AppLanguage.spanish;
      case 'fr':
        return AppLanguage.french;
      case 'de':
        return AppLanguage.german;
      case 'ne':
        return AppLanguage.nepali;
      default:
        return AppLanguage.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble(); // 5% of width
    final themeMode = ref.watch(themeProvider);

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
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'settings'.tr(),
        subtitle: "managePreferences".tr(),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('account'.tr()),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'editProfile'.tr(),
              subtitle: 'updatePersonalInfo'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'privacySecurity'.tr(),
              subtitle: 'managePrivacy'.tr(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('privacyComingSoon'.tr())),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'changePassword'.tr(),
              subtitle: 'updatePassword'.tr(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('changePasswordComingSoon'.tr())),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Appearance Section
            _buildSectionHeader('appearance'.tr()),
            const SizedBox(height: AppSpacing.sm),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'darkMode'.tr(),
              subtitle: 'enableDarkTheme'.tr(),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                if (value) {
                  ref.read(themeProvider.notifier).setDark();
                  return;
                }
                ref.read(themeProvider.notifier).setLight();
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'language'.tr(),
              subtitle: _getLanguageDisplayName(_selectedLanguageCode),
              onTap: () {
                _showLanguageDialog();
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Support Section
            _buildSectionHeader('support'.tr()),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'helpCenter'.tr(),
              subtitle: 'getHelp'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'about'.tr(),
              subtitle: 'appVersion'.tr(),
              onTap: () {
                _showAboutDialog();
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.rate_review_outlined,
              title: 'rateApp'.tr(),
              subtitle: 'shareFeeling'.tr(),
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('thankYou'.tr())));
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Legal Section
            _buildSectionHeader('legal'.tr()),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'privacyPolicy'.tr(),
              subtitle: 'viewPrivacy'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'termsOfService'.tr(),
              subtitle: 'viewTerms'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
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
                icon: Icon(Icons.logout, color: colorScheme.error),
                label: Text(
                  'logout'.tr(),
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error, width: 1.5),
                  backgroundColor: colorScheme.surface,
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
    final textTheme = Theme.of(context).textTheme;

    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
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
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
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
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
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
        title: Text('selectLanguage'.tr()),
        content: RadioGroup<String>(
          groupValue: _selectedLanguageCode,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            Navigator.pop(context);
            _changeLanguage(value);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('english'.tr(), 'en'),
              _buildLanguageOption('spanish'.tr(), 'es'),
              _buildLanguageOption('french'.tr(), 'fr'),
              _buildLanguageOption('german'.tr(), 'de'),
              _buildLanguageOption('nepali'.tr(), 'ne'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, String code) {
    return RadioListTile<String>(
      title: Text(language),
      value: code,
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
        child: const Icon(Icons.shopping_bag, color: Colors.white, size: 30),
      ),
      children: [Text('completeShoppingSolution'.tr())],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutDialog(
        onConfirm: () {
          ref.read(authViewModelProvider.notifier).logout();
        },
      ),
    );
  }
}
