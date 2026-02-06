import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'privacyPolicy'.tr(),
        subtitle: 'privacyPolicySubtitle'.tr(),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Text(
              '${'lastUpdated'.tr()}: February 6, 2026',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Introduction
            _buildSection(
              context,
              title: 'introduction'.tr(),
              content: 'privacyIntroduction'.tr(),
            ),

            // Information We Collect
            _buildSection(
              context,
              title: 'informationWeCollect'.tr(),
              content: 'informationWeCollectContent'.tr(),
            ),

            // How We Use Information
            _buildSection(
              context,
              title: 'howWeUseInformation'.tr(),
              content: 'howWeUseInformationContent'.tr(),
            ),

            // Information Sharing
            _buildSection(
              context,
              title: 'informationSharing'.tr(),
              content: 'informationSharingContent'.tr(),
            ),

            // Data Security
            _buildSection(
              context,
              title: 'dataSecurity'.tr(),
              content: 'dataSecurityContent'.tr(),
            ),

            // Your Rights
            _buildSection(
              context,
              title: 'yourRights'.tr(),
              content: 'yourRightsContent'.tr(),
            ),

            // Contact Us
            _buildSection(
              context,
              title: 'contactUs'.tr(),
              content: 'contactUsContent'.tr(),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}