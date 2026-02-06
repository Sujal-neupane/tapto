import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tapto/core/providers/currency_provider.dart';
import 'package:tapto/core/utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tapto/features/dashboard/presentation/provider/wishlist_provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/api/api_endpoint.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../orders/presentation/viewmodel/order_viewmodel.dart';
import '../../../orders/presentation/pages/order_tracking_screen.dart';
import 'edit_profile_screen.dart';
import '../../../addresses/presentation/pages/addresses_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch orders to get accurate count for profile stats
    Future.microtask(() {
      ref.read(orderViewModelProvider.notifier).fetchMyOrders();
    });
  }

  // Show bottom sheet for image source selection
  Future<void> _showPickOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Profile Photo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.surface,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primary,
              ),
              title: Text(context.translate('Take a Photo')),
              onTap: () {
                Navigator.pop(context);
                _handleImagePick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primary,
              ),
              title: Text(context.translate('Choose from Gallery')),
              onTap: () {
                Navigator.pop(context);
                _handleImagePick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePick(ImageSource source) async {
    try {
      // On iOS simulator, skip permission check and go directly to image picker
      // iOS simulators have issues with permission dialogs
      if (Platform.isIOS) {
        debugPrint('iOS detected, attempting direct image pick');
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          debugPrint('Image picked successfully on iOS: ${pickedFile.path}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.translate('Uploading profile picture...'))),
          );
          await ref
              .read(authViewModelProvider.notifier)
              .uploadProfilePicture(File(pickedFile.path));
        } else {
          debugPrint('Image picker returned null on iOS');
        }
        return;
      }

      // For Android and other platforms, use normal permission flow
      PermissionStatus permissionStatus;
      if (source == ImageSource.camera) {
        debugPrint('Requesting camera permission...');
        permissionStatus = await Permission.camera.request();
        debugPrint('Camera permission status: $permissionStatus');
      } else {
        debugPrint('Requesting storage permission...');
        permissionStatus = await Permission.storage.request();
        debugPrint('Storage permission status: $permissionStatus');
      }

      // If permission is denied, show dialog
      if (!permissionStatus.isGranted && permissionStatus != PermissionStatus.limited) {
        if (permissionStatus == PermissionStatus.permanentlyDenied) {
          debugPrint('Permission permanently denied, opening settings directly');
          _showSettingsDialog();
        } else {
          debugPrint('Permission not granted, showing dialog');
          _showPermissionDialog(source);
        }
        return;
      }

      // If limited access on iOS, show message but continue
      if (permissionStatus == PermissionStatus.limited) {
        debugPrint('Limited permission granted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.translate('Limited photo access granted. You can still select photos.'))),
        );
      }

      debugPrint('Permission granted, attempting to pick image...');
      // Now try to pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        debugPrint('Image picked successfully: ${pickedFile.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.translate('Uploading profile picture...'))),
        );
        try {
          await ref
              .read(authViewModelProvider.notifier)
              .uploadProfilePicture(File(pickedFile.path));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.translate('Profile picture updated successfully!'))),
          );
        } catch (uploadError) {
          debugPrint('Upload failed: $uploadError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload profile picture: ${uploadError.toString()}')),
          );
        }
      } else {
        debugPrint('Image picker returned null');
      }
    } catch (e) {
      debugPrint('Error in _handleImagePick: $e');
      // If image picking fails, check if it's due to permissions
      if (e.toString().contains('permission') ||
          e.toString().contains('Permission') ||
          e.toString().contains('denied') ||
          e.toString().contains('not authorized')) {
        _showPermissionDialog(source);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    }
  }

  void _showPermissionDialog(ImageSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('Permission Required')),
        content: Text(context.translate('This app needs ${source == ImageSource.camera ? 'camera' : 'photo library'} access to ${source == ImageSource.camera ? 'take photos' : 'select photos'}. Please enable it in Settings.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.translate('Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(context.translate('Open Settings')),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('Permission Required')),
        content: Text(context.translate('Please enable permissions in settings to change your photo.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.translate('Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(context.translate('Settings')),
          ),
        ],
      ),
    );
  }

  // Show bottom sheet with all orders and track buttons (unchanged)
  void _showTrackOrderSheet(BuildContext context, WidgetRef ref) async {
    await ref.read(orderViewModelProvider.notifier).fetchMyOrders();
    final orders = ref.read(orderViewModelProvider).orders;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: orders.isEmpty
              ? Center(child: Text('No orders to track.'))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(
                      leading: Icon(
                        Icons.shopping_bag,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Order #${order.id.substring(order.id.length - 6)}',
                      ),
                      subtitle: Text(
                        'Status: ${order.status.name[0].toUpperCase()}${order.status.name.substring(1)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Track'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderTrackingScreen(orderId: order.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    final userName = currentUser?.name ?? 'Guest User';
    final userEmail = currentUser?.email ?? 'guest@tapto.com';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';

    final profileImageUrl = currentUser?.profilePicture;
    print('Profile picture path: ${currentUser?.profilePicture}');
    print('Profile image URL: $profileImageUrl');

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),

              // Profile Header with Avatar and Stats
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
                    // Avatar with Camera Icon
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                              ? NetworkImage(
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
                            onTap: _showPickOptions,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                              label: 'Orders',
                            ),
                            const _VerticalDivider(),
                            _StatItem(
                              icon: Icons.favorite_outline,
                              count: '$wishlistCount',
                              label: 'Wishlist',
                            ),
                            const _VerticalDivider(),
                            const _StatItem(
                              icon: Icons.star_outline,
                              count: '4.8',
                              label: 'Reviews',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Quick Actions Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Actions',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
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
                      title: 'Wishlist',
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
                      title: 'Track Order',
                      color: Colors.orange,
                      onTap: () => _showTrackOrderSheet(context, ref),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Invoices',
                      color: Colors.green,
                      onTap: () {
                        // Navigate to orders screen where invoices can be downloaded
                        Navigator.pushNamed(context, AppRoutes.myOrders);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tap on an order to download its invoice',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

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
                    MaterialPageRoute(
                      builder: (_) => const AddressesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProfileMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage your payment options',
                onTap: () => _showPaymentMethodsDialog(context, ref),
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

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------
// Stats Widget
// --------------------
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// Vertical Divider between stats
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: Colors.grey[300]);
  }
}

// --------------------
// Quick Action Card Widget
// --------------------
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------
// Payment Methods Dialog
// --------------------
void _showPaymentMethodsDialog(BuildContext context, WidgetRef ref) {
  final paymentMethods = ref.read(paymentMethodsProvider);
  final currency = ref.read(currencyProvider);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Payment Methods'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available payment methods for your region:'),
          const SizedBox(height: 16),
          ...paymentMethods.map((method) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.payment, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(method),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Text('Currency: ${currency.toString()}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

// --------------------
// Profile Menu Item Widget
// --------------------
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
