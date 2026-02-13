import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/core/providers/currency_provider.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import 'package:tapto/core/widgets/cached_image.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/orders/presentation/pages/my_orders_screen.dart';
import 'package:tapto/features/orders/presentation/viewmodel/order_viewmodel.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/features/addresses/presentation/viewmodel/address_viewmodel.dart';
import 'package:tapto/features/addresses/domain/entities/address_entity.dart';
import 'package:tapto/core/services/khalti_payment_service.dart';
import 'package:tapto/core/services/esewa_payment_service.dart';
import 'package:tapto/core/services/biometric_auth_service.dart';
import 'package:tapto/features/dashboard/presentation/widgets/checkout_progress_indicator.dart';
import 'package:tapto/features/dashboard/presentation/widgets/order_summary_card.dart';
import 'package:tapto/features/dashboard/presentation/widgets/shipping_address_section.dart';
import 'package:tapto/features/dashboard/presentation/widgets/payment_method_section.dart';
import 'package:tapto/features/dashboard/presentation/widgets/order_details_card.dart';
import 'package:tapto/features/dashboard/presentation/widgets/checkout_bottom_bar.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  String _selectedPayment = 'COD';
  String? _userCountry;
  bool _isPlacingOrder = false;
  Map<String, String>? _shippingAddress;
  String? _userName;
  String? _userPhone;
  AddressEntity? _selectedSavedAddress;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController.forward();
    _fadeController.forward();

    // Load user data and addresses
    _loadUserData();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userSessionService = ref.read(userSessionServiceProvider);
      final user = await userSessionService.getCurrentUser();
      if (user != null) {
        setState(() {
          _userName = user.name;
          _userPhone = user.phoneNumber;
          _userCountry = user.country;
        });
      }

      // Set default payment to first available method for user's country
      final methods = ref.read(paymentMethodsProvider);
      if (methods.isNotEmpty) {
        setState(() {
          _selectedPayment = methods.first.id;
        });
      }

      // Load user addresses
      await ref.read(addressViewModelProvider.notifier).loadUserAddresses();

      // Auto-select default address if available
      final addressState = ref.read(addressViewModelProvider);
      final defaultAddress = addressState.addresses
          .where((addr) => addr.isDefault)
          .firstOrNull;
      if (defaultAddress != null && mounted) {
        setState(() {
          _selectedSavedAddress = defaultAddress;
        });
      }
    } catch (e) {
      // Handle error silently
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _handlePaymentSelection(String paymentId) async {
    // If not COD, Khalti, or eSewa, show mock payment dialog
    if (paymentId != 'COD' &&
        paymentId.toLowerCase() != 'khalti' &&
        paymentId.toLowerCase() != 'esewa') {
      final paid = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Simulate $paymentId Payment'),
          content: Text(
            'This is a mock payment for $paymentId. Press Pay to simulate a successful payment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(AppColors.surface),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Pay'),
            ),
          ],
        ),
      );
      if (paid == true) {
        // Show a success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('$paymentId payment successful!')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // If cancelled, revert to COD
        setState(() => _selectedPayment = 'COD');
      }
    }
  }

  String Function(double) get currencyFormatter =>
      ref.watch(currencyFormatterProvider);

  Future<void> _showAddressModal(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _AddressSelectionModal(
        selectedAddress: _selectedSavedAddress,
        onAddressSelected: (address) {
          setState(() {
            _selectedSavedAddress = address;
            _shippingAddress =
                null; // Clear manual address when saved address is selected
          });
        },
        onManualAddressEntered: (addressData) {
          setState(() {
            _shippingAddress = addressData;
            _selectedSavedAddress =
                null; // Clear saved address when manual address is entered
          });
        },
      ),
    );
    if (result != null) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _placeOrder(List<CartItemModel> cartItems, double total) async {
    // Check if an address is selected
    if (_selectedSavedAddress == null &&
        (_shippingAddress == null ||
            _shippingAddress!['phone'] == null ||
            _shippingAddress!['phone']!.isEmpty)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Please select or enter a valid shipping address.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isPlacingOrder = true);

    try {
      // Handle Khalti payment
      if (_selectedPayment.toLowerCase() == 'khalti') {
        await _handleKhaltiPayment(cartItems, total);
        return;
      }

      // Handle eSewa payment
      if (_selectedPayment.toLowerCase() == 'esewa') {
        await _handleESewaPayment(cartItems, total);
        return;
      }

      final paymentMethod = {
        'id': _selectedPayment.toLowerCase(),
        'type': _selectedPayment == 'COD'
            ? 'Cash on Delivery'
            : _selectedPayment,
      };

      // Prepare address data
      Map<String, String> addressData;
      if (_selectedSavedAddress != null) {
        // Use saved address
        addressData = {
          'id': _selectedSavedAddress!.id,
          'fullName': _selectedSavedAddress!.fullName,
          'phone': _selectedSavedAddress!.phone,
          'street': _selectedSavedAddress!.street,
          'city': _selectedSavedAddress!.city,
          'state': _selectedSavedAddress!.state ?? '',
          'zipCode': _selectedSavedAddress!.zipCode,
          'country': _selectedSavedAddress!.country,
        };
      } else {
        // Use manual address
        addressData = {
          'id': 'manual-address',
          'fullName': _shippingAddress!['fullName'] ?? '',
          'phone': _shippingAddress!['phone'] ?? '',
          'street': _shippingAddress!['street'] ?? '',
          'city': _shippingAddress!['city'] ?? '',
          'state': _shippingAddress!['state'] ?? '',
          'zipCode': _shippingAddress!['zipCode'] ?? '',
          'country': _shippingAddress!['country'] ?? '',
        };
      }

      // Validate required fields
      if (addressData['state'] == null || addressData['state']!.isEmpty) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('State is required for shipping address.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        setState(() => _isPlacingOrder = false);
        return;
      }

      await ref
          .read(orderViewModelProvider.notifier)
          .createOrderFromCart(
            cartItems
                .map(
                  (e) => CartItemModel(
                    productId: e.productId,
                    productName: e.productName,
                    productImage: e.productImage,
                    price: e.price,
                    quantity: e.quantity,
                    size: e.size,
                    color: e.color,
                  ),
                )
                .toList(),
            address: addressData,
            payment: paymentMethod,
          );

      ref.read(cartViewModelProvider.notifier).clearCart();

      if (!mounted) return;
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Order placed successfully!')),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MyOrdersScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Failed to place order: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _handleKhaltiPayment(List<CartItemModel> cartItems, double total) async {

    final bool biometricAvailable = await BiometricAuthService.isBiometricAvailable();
    
    if (biometricAvailable) {
      // Attempt biometric authentication
      final bool authenticated = await BiometricAuthService.authenticate(
        reason: 'Authenticate to proceed with Khalti payment',
      );
      
      if (!authenticated) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication failed. Payment cancelled.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isPlacingOrder = false);
        return;
      }
    }
    try {
      await KhaltiPaymentService.initiatePayment(
        context: context,
        amount: total,
        productName: 'TapTo Order',
        productId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        onSuccess: (String pidx) async {
          // Payment successful, now place the order
          await _placeOrderAfterPayment(cartItems, total, pidx);
        },
        onError: (String error) {
          if (!mounted) return;
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Payment failed: $error')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          setState(() => _isPlacingOrder = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Payment initialization failed: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() => _isPlacingOrder = false);
    }
  }

  Future<void> _handleESewaPayment(List<CartItemModel> cartItems, double total) async {
    final bool biometricAvailable = await BiometricAuthService.isBiometricAvailable();
    
    if (biometricAvailable) {
      // Attempt biometric authentication
      final bool authenticated = await BiometricAuthService.authenticate(
        reason: 'Authenticate to proceed with eSewa payment',
      );
      
      if (!authenticated) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication failed. Payment cancelled.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isPlacingOrder = false);
        return;
      }
    }
    try {
      await ESewaPaymentService.initiatePayment(
        context: context,
        amount: total,
        productName: 'TapTo Order',
        productId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        onSuccess: (String refId) async {
          // Payment successful, now place the order
          await _placeOrderAfterPayment(cartItems, total, refId);
        },
        onError: (String error) {
          if (!mounted) return;
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Payment failed: $error')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          setState(() => _isPlacingOrder = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Payment initialization failed: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() => _isPlacingOrder = false);
    }
  }

  Future<void> _placeOrderAfterPayment(List<CartItemModel> cartItems, double total, String pidx) async {
    try {
      final paymentMethod = {
        'id': 'khalti',
        'type': 'Khalti',
        'pidx': pidx,
      };

      // Prepare address data (same as in _placeOrder)
      Map<String, String> addressData;
      if (_selectedSavedAddress != null) {
        addressData = {
          'id': _selectedSavedAddress!.id,
          'fullName': _selectedSavedAddress!.fullName,
          'phone': _selectedSavedAddress!.phone,
          'street': _selectedSavedAddress!.street,
          'city': _selectedSavedAddress!.city,
          'state': _selectedSavedAddress!.state ?? '',
          'zipCode': _selectedSavedAddress!.zipCode,
          'country': _selectedSavedAddress!.country,
        };
      } else {
        addressData = {
          'id': 'manual-address',
          'fullName': _shippingAddress!['fullName'] ?? '',
          'phone': _shippingAddress!['phone'] ?? '',
          'street': _shippingAddress!['street'] ?? '',
          'city': _shippingAddress!['city'] ?? '',
          'state': _shippingAddress!['state'] ?? '',
          'zipCode': _shippingAddress!['zipCode'] ?? '',
          'country': _shippingAddress!['country'] ?? '',
        };
      }

      await ref
          .read(orderViewModelProvider.notifier)
          .createOrderFromCart(
            cartItems
                .map(
                  (e) => CartItemModel(
                    productId: e.productId,
                    productName: e.productName,
                    productImage: e.productImage,
                    price: e.price,
                    quantity: e.quantity,
                    size: e.size,
                    color: e.color,
                  ),
                )
                .toList(),
            address: addressData,
            payment: paymentMethod,
          );

      ref.read(cartViewModelProvider.notifier).clearCart();

      if (!mounted) return;
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Order placed successfully!')),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MyOrdersScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Failed to place order: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartViewModelProvider);
    final cartItems = cart.items.map((item) => CartItemModel.fromEntity(item)).toList();
    final total = cart.total;
    final paymentMethods = ref.watch(paymentMethodsProvider);
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;
    final isTablet = screenSize.width > 600;
    final padding = (screenSize.width * 0.04).toDouble(); // 4% of width
    final iconSize = min(
      80.0,
      screenSize.width * 0.15,
    ); // Max 80, or 15% of width
    final titleFontSize = min(
      20.0,
      18 * textScaler.scale(1.0) * (isTablet ? 1.1 : 1.0),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: iconSize,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      children: [
                        // Progress Indicator
                        const CheckoutProgressIndicator(),
                        const SizedBox(height: 24),

                        // Order Summary
                        OrderSummaryCard(cartItems: cartItems),
                        const SizedBox(height: 16),

                        // Shipping Address
                        ShippingAddressSection(
                          selectedSavedAddress: _selectedSavedAddress,
                          shippingAddress: _shippingAddress,
                          onAddEditAddress: () => _showAddressModal(context),
                        ),
                        const SizedBox(height: 16),

                        // Payment Method
                        PaymentMethodSection(
                          paymentMethods: paymentMethods,
                          selectedPayment: _selectedPayment,
                          onPaymentSelected: (paymentId) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedPayment = paymentId);
                            // Handle mock payments if needed
                            _handlePaymentSelection(paymentId);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Order Details Summary
                        OrderDetailsCard(cartItems: cartItems),
                      ],
                    ),

                    // Floating Bottom Bar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CheckoutBottomBar(
                        cartItems: cartItems,
                        cartTotal: total,
                        isPlacingOrder: _isPlacingOrder,
                        onPlaceOrder: () => _placeOrder(cartItems, total),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppCachedImage(
              imageUrl: item.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildItemDetail(Icons.straighten, item.size ?? ''),
                    const SizedBox(width: 12),
                    _buildItemDetail(Icons.palette_outlined, item.color ?? ''),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ref.watch(currencyFormatterProvider)(item.price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _selectedPayment == value;
    return InkWell(
      onTap: () async {
        HapticFeedback.selectionClick();
        setState(() => _selectedPayment = value);
        // If not COD, Khalti, or eSewa, show mock payment dialog
        if (value != 'COD' && value.toLowerCase() != 'khalti' && value.toLowerCase() != 'esewa') {
          final paid = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Simulate $label Payment'),
              content: Text(
                'This is a mock payment for $label. Press Pay to simulate a successful payment.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(AppColors.surface),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Pay'),
                ),
              ],
            ),
          );
          if (paid == true) {
            // Show a success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('$label payment successful!')),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            // If cancelled, revert to COD
            setState(() => _selectedPayment = 'COD');
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 15,
                  color: isSelected ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        isFree
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              )
            : Text(
                currencyFormatter(amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
      ],
    );
  }

}

// Removed duplicate _AddressModal class - using the updated version below

// --- Address Modal Widget ---
class _AddressModal extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;

  const _AddressModal({this.initialName, this.initialPhone});

  @override
  State<_AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<_AddressModal>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoadingLocation = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _scaleController.forward();

    // Pre-fill name and phone from user data
    _fullNameController.text = widget.initialName ?? '';
    _phoneController.text = widget.initialPhone ?? '';
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showLocationSettingsDialog();
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode to get address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          // Clear house number field for user input
          _streetController.text = ''; // House number will be entered by user
          _cityController.text =
              place.locality ?? place.subAdministrativeArea ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _zipController.text = place.postalCode ?? '';
          _countryController.text = place.country ?? 'Nepal';
        });

        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Address filled from your location!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in settings for easier address input.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop({
        'id': 'default-address',
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipController.text.trim(),
        'country': _countryController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Use Current Location Button
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: OutlinedButton.icon(
                            onPressed: _isLoadingLocation
                                ? null
                                : _useCurrentLocation,
                            icon: _isLoadingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location, size: 20),
                            label: Text(
                              _isLoadingLocation
                                  ? 'Getting location...'
                                  : 'Use Current Location',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        _AddressField(
                          icon: Icons.person_outline,
                          label: 'Full Name',
                          controller: _fullNameController,
                          hint: 'Enter your full name',
                        ),
                        const SizedBox(height: 16),
                        _AddressField(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          hint: '+977 98XXXXXXXX',
                        ),
                        const SizedBox(height: 16),
                        _AddressField(
                          icon: Icons.home_outlined,
                          label: 'House Number',
                          controller: _streetController,
                          hint: 'Enter house number',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _AddressField(
                                icon: Icons.location_city_outlined,
                                label: 'City',
                                controller: _cityController,
                                hint: 'City',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AddressField(
                                icon: Icons.map_outlined,
                                label: 'State',
                                controller: _stateController,
                                hint: 'State',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _AddressField(
                                icon: Icons.local_post_office_outlined,
                                label: 'Zip Code',
                                controller: _zipController,
                                keyboardType: TextInputType.number,
                                hint: '44600',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AddressField(
                                icon: Icons.flag_outlined,
                                label: 'Country',
                                controller: _countryController,
                                hint: 'Nepal',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Save Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Custom Address Field Widget ---
class _AddressField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;

  const _AddressField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}

class _AddressSelectionModal extends ConsumerStatefulWidget {
  final AddressEntity? selectedAddress;
  final Function(AddressEntity?) onAddressSelected;
  final Function(Map<String, String>) onManualAddressEntered;

  const _AddressSelectionModal({
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onManualAddressEntered,
  });

  @override
  ConsumerState<_AddressSelectionModal> createState() =>
      _AddressSelectionModalState();
}

class _AddressSelectionModalState extends ConsumerState<_AddressSelectionModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoadingLocation = false;
  final int _currentStep = 0; // 0 = contact, 1 = address

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _countryController.text = 'Nepal';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _submitManualAddress() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      final addressData = {
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
        'country': _countryController.text.trim(),
      };
      widget.onManualAddressEntered(addressData);
      Navigator.of(context).pop();
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.location_off, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Please enable location services'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _streetController.text = '';
          _cityController.text = place.locality ?? place.subAdministrativeArea ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _zipCodeController.text = place.postalCode ?? '';
          _countryController.text = place.country ?? 'Nepal';
        });

        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Location detected! Enter your street address.'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to detect location: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressViewModelProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ─── Header ───
          _buildHeader(),
          // ─── Tab Content ───
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSavedAddressesTab(addressState),
                _buildManualEntryTab(bottomInset),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Where should we deliver your order?',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tab bar
          Container(
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[500],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_outline, size: 16),
                      SizedBox(width: 6),
                      Text('Saved'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_location_alt_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('New Address'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSavedAddressesTab(AddressState addressState) {
    if (addressState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (addressState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off_rounded, size: 40, color: Colors.red[400]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Couldn\'t load addresses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                addressState.errorMessage!,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(addressViewModelProvider.notifier).loadUserAddresses(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (addressState.addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_location_alt_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No saved addresses yet',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new address to speed up\nfuture checkouts',
                style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add New Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: addressState.addresses.length,
      itemBuilder: (context, index) {
        final address = addressState.addresses[index];
        final isSelected = widget.selectedAddress?.id == address.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onAddressSelected(address);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.04)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Radio indicator
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Address content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  address.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 13, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Text(
                                address.phone,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(Icons.place_outlined, size: 13, color: Colors.grey[500]),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${address.street}, ${address.city}${address.state != null ? ', ${address.state}' : ''} ${address.zipCode}, ${address.country}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildManualEntryTab(double bottomInset) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPS Auto-fill Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoadingLocation ? null : _useCurrentLocation,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.06),
                        AppColors.primary.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isLoadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoadingLocation ? 'Detecting location...' : 'Use Current Location',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Auto-fill city, state, and country',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Section: Contact Info ───
            _buildSectionLabel('Contact Information', Icons.person_outline),
            const SizedBox(height: 12),
            _StyledAddressField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'e.g. Sujal Neupane',
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _StyledAddressField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+977 98XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // ─── Section: Address ───
            _buildSectionLabel('Delivery Address', Icons.location_on_outlined),
            const SizedBox(height: 12),
            _StyledAddressField(
              controller: _streetController,
              label: 'Street / House No.',
              hint: 'e.g. 123 Main Street',
              icon: Icons.home_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StyledAddressField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'e.g. Kathmandu',
                    icon: Icons.location_city_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StyledAddressField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'e.g. Bagmati',
                    icon: Icons.map_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StyledAddressField(
                    controller: _zipCodeController,
                    label: 'ZIP Code',
                    hint: '44600',
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StyledAddressField(
                    controller: _countryController,
                    label: 'Country',
                    hint: 'Nepal',
                    icon: Icons.flag_outlined,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitManualAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Use This Address',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ],
    );
  }
}

/// Modern styled form field for the address modal
class _StyledAddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _StyledAddressField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: (v) =>
          v == null || v.trim().isEmpty ? '$label is required' : null,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
