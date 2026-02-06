import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'helpCenter'.tr(),
        subtitle: 'getHelp'.tr(),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'searchHelp'.tr(),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // FAQ Section
            _buildSectionHeader(context, 'frequentlyAskedQuestions'.tr()),
            const SizedBox(height: AppSpacing.md),

            _buildFAQItem(
              context,
              question: 'howToPlaceOrder'.tr(),
              answer: 'howToPlaceOrderAnswer'.tr(),
            ),
            _buildFAQItem(
              context,
              question: 'paymentMethods'.tr(),
              answer: 'paymentMethodsAnswer'.tr(),
            ),
            _buildFAQItem(
              context,
              question: 'deliveryTime'.tr(),
              answer: 'deliveryTimeAnswer'.tr(),
            ),
            _buildFAQItem(
              context,
              question: 'returnPolicy'.tr(),
              answer: 'returnPolicyAnswer'.tr(),
            ),
            _buildFAQItem(
              context,
              question: 'contactSupport'.tr(),
              answer: 'contactSupportAnswer'.tr(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Contact Support Section
            _buildSectionHeader(context, 'contactSupport'.tr()),
            const SizedBox(height: AppSpacing.md),

            _buildContactOption(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'liveChat'.tr(),
              subtitle: 'chatWithSupport'.tr(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('liveChatComingSoon'.tr())),
                );
              },
            ),

            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              title: 'emailSupport'.tr(),
              subtitle: 'sendEmail'.tr(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('emailSupportComingSoon'.tr())),
                );
              },
            ),

            _buildContactOption(
              context,
              icon: Icons.phone_outlined,
              title: 'callSupport'.tr(),
              subtitle: 'speakWithAgent'.tr(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('callSupportComingSoon'.tr())),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              answer,
              style: AppTextStyles.caption?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}