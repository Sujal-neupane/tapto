import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tapto/core/providers/currency_provider.dart';
import 'package:tapto/core/utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../../../orders/presentation/viewmodel/order_viewmodel.dart';
import '../../../orders/presentation/pages/order_tracking_screen.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/account_section.dart';

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
            SnackBar(
              content: Text(context.translate('Uploading profile picture...')),
            ),
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
      if (!permissionStatus.isGranted &&
          permissionStatus != PermissionStatus.limited) {
        if (permissionStatus == PermissionStatus.permanentlyDenied) {
          debugPrint(
            'Permission permanently denied, opening settings directly',
          );
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
          SnackBar(
            content: Text(
              context.translate(
                'Limited photo access granted. You can still select photos.',
              ),
            ),
          ),
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
          SnackBar(
            content: Text(context.translate('Uploading profile picture...')),
          ),
        );
        try {
          await ref
              .read(authViewModelProvider.notifier)
              .uploadProfilePicture(File(pickedFile.path));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.translate('Profile picture updated successfully!'),
              ),
            ),
          );
        } catch (uploadError) {
          debugPrint('Upload failed: $uploadError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload profile picture: ${uploadError.toString()}',
              ),
            ),
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
        content: Text(
          context.translate(
            'This app needs ${source == ImageSource.camera ? 'camera' : 'photo library'} access to ${source == ImageSource.camera ? 'take photos' : 'select photos'}. Please enable it in Settings.',
          ),
        ),
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
        content: Text(
          context.translate(
            'Please enable permissions in settings to change your photo.',
          ),
        ),
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
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble(); // 5% of width

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),

              // Profile Header with Avatar and Stats
              ProfileHeaderCard(onAvatarTap: _showPickOptions),

              const SizedBox(height: AppSpacing.xl),

              // Quick Actions Section
              QuickActionsSection(onTrackOrderTap: () => _showTrackOrderSheet(context, ref)),

              const SizedBox(height: AppSpacing.xl),

              // Account Section
              AccountSection(onPaymentMethodsTap: () => _showPaymentMethodsDialog(context, ref)),

              const SizedBox(height: AppSpacing.lg),
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
          ...paymentMethods.map(
            (method) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(method.icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(method.label)),
                ],
              ),
            ),
          ),
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
