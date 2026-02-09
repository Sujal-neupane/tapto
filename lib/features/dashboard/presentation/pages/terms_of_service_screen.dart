import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';


class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'termsOfService'.tr(),
        subtitle: 'termsOfServiceSubtitle'.tr(),
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
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Acceptance of Terms
            _buildSection(
              title: 'acceptanceOfTerms'.tr(),
              content: 'acceptanceOfTermsContent'.tr(),
            ),

            // Use of Service
            _buildSection(
              title: 'useOfService'.tr(),
              content: 'useOfServiceContent'.tr(),
            ),

            // User Accounts
            _buildSection(
              title: 'userAccounts'.tr(),
              content: 'userAccountsContent'.tr(),
            ),

            // Orders and Payment
            _buildSection(
              title: 'ordersAndPayment'.tr(),
              content: 'ordersAndPaymentContent'.tr(),
            ),

            // Shipping and Delivery
            _buildSection(
              title: 'shippingAndDelivery'.tr(),
              content: 'shippingAndDeliveryContent'.tr(),
            ),

            // Returns and Refunds
            _buildSection(
              title: 'returnsAndRefunds'.tr(),
              content: 'returnsAndRefundsContent'.tr(),
            ),

            // Intellectual Property
            _buildSection(
              title: 'intellectualProperty'.tr(),
              content: 'intellectualPropertyContent'.tr(),
            ),

            // Limitation of Liability
            _buildSection(
              title: 'limitationOfLiability'.tr(),
              content: 'limitationOfLiabilityContent'.tr(),
            ),

            // Contact Information
            _buildSection(
              title: 'contactInformation'.tr(),
              content: 'contactInformationContent'.tr(),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}