import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/providers/app_providers.dart';
import 'package:tapto/core/utils/image_utils.dart';
import 'package:tapto/core/widgets/cached_image.dart';
import 'package:tapto/core/services/sensor_service.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/presentation/pages/product_details_screen.dart';
import 'package:tapto/features/dashboard/presentation/provider/wishlist_provider.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import 'package:tapto/features/products/data/models/product_model.dart';
import 'package:tapto/features/products/presentation/providers/product_providers.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class HomeSwipeScreen extends ConsumerStatefulWidget {
  const HomeSwipeScreen({super.key});

  @override
  ConsumerState<HomeSwipeScreen> createState() => _HomeSwipeScreenState();
}

class _HomeSwipeScreenState extends ConsumerState<HomeSwipeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  late AnimationController _animationController;
  StreamSubscription<ShakeDirection>? _shakeSubscription;
  StreamSubscription<bool>? _proximitySubscription;
  StreamSubscription<DeviceOrientation>? _orientationSubscription;
  bool _shakeEnabled = true; // Toggle for shake gestures
  bool _isPausedByProximity =
      false; // Track if browsing is paused due to proximity

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start listening to shake gestures
    _startShakeListening();

    // Start listening to proximity sensor
    _startProximityListening();

    // Start listening to orientation changes
    _startOrientationListening();
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _proximitySubscription?.cancel();
    _orientationSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String Function(double) get currencyFormatter =>
      ref.watch(currencyFormatterProvider);

  void _resetDrag() {
    setState(() => _dragOffset = Offset.zero);
  }

  /// Start listening to shake gestures
  void _startShakeListening() {
    final sensorService = ref.read(sensorServiceProvider);
    sensorService.startListening(); // Always start listening for shake gestures

    _shakeSubscription = sensorService.shakeStream.listen(_handleShake);
  }

  void _toggleShakeGestures() {
    setState(() => _shakeEnabled = !_shakeEnabled);

    // Show feedback but don't stop sensor listening
    if (_shakeEnabled) {
      _showShakeFeedback('Shake gestures enabled!', Colors.green);
    } else {
      _showShakeFeedback('Shake gestures disabled!', Colors.orange);
    }
  }

  void _startProximityListening() {
    final sensorService = ref.read(sensorServiceProvider);
    sensorService.startListening(); // Ensure sensors are started

    _proximitySubscription = sensorService.proximityStream.listen((isNearFace) {
      setState(() => _isPausedByProximity = isNearFace);

      if (isNearFace) {
        _showShakeFeedback(
          'Phone detected on table - browsing paused',
          Colors.blue,
        );
      } else {
        _showShakeFeedback('Browsing resumed', Colors.green);
      }
    });
  }

  void _startOrientationListening() {
    final sensorService = ref.read(sensorServiceProvider);
    sensorService.startListening(); // Ensure sensors are started

    _orientationSubscription = sensorService.orientationStream.listen((
      orientation,
    ) {
      // Orientation is monitored through the sensor service
      // Current orientation is obtained from MediaQuery.of(context).orientation
    });
  }

  /// Handle shake gestures
  void _handleShake(ShakeDirection direction) {
    // Don't handle shake gestures if disabled or if browsing is paused by proximity
    if (!_shakeEnabled || _isPausedByProximity) return;

    final productsAsync = ref.read(userProductsProvider);

    productsAsync.whenData((products) {
      if (products.isEmpty || _currentIndex >= products.length) return;

      switch (direction) {
        case ShakeDirection.right:
          // Add to cart
          _addToCart(products[_currentIndex]);
          _showShakeFeedback('Added to cart!', Colors.green);
          // Move to next product
          _swipeToNext();
          break;

        case ShakeDirection.left:
          // Skip product
          _showShakeFeedback('Skipped!', Colors.orange);
          // Move to next product
          _swipeToNext();
          break;

        case ShakeDirection.none:
          // Do nothing
          break;
      }
    });
  }

  /// Show feedback for shake actions
  void _showShakeFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Swipe to next product
  void _swipeToNext() {
    final productsAsync = ref.read(userProductsProvider);

    productsAsync.whenData((products) {
      setState(() {
        _currentIndex++;
        _dragOffset = Offset.zero;
      });
    });
  }

  /// Helper to convert relative image path to full URL
  String _getImageUrl(String imagePath) {
    return ImageUtils.getImageUrl(imagePath);
  }

  void _addToCart(ProductModel product) {
    final imageUrl = product.images.isNotEmpty
        ? _getImageUrl(product.images.first)
        : '';

    ref
        .read(cartViewModelProvider.notifier)
        .addItem(
          CartItemModel(
            productId: product.id,
            productName: product.name,
            productImage: imageUrl,
            price: product.price,
            quantity: 1,
            size: product.sizes.isNotEmpty ? product.sizes.first : '',
            color: product.colors.isNotEmpty ? product.colors.first : '',
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.name} ${'addedToCart'.tr()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addToWishlist(ProductModel product) {
    final isInWishlist = ref
        .read(wishlistProvider)
        .any((p) => p.id == product.id);

    if (isInWishlist) {
      ref.read(wishlistProvider.notifier).removeFromWishlist(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.favorite_border, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product.name} ${'removedFromWishlist'.tr()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ref.read(wishlistProvider.notifier).addToWishlist(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product.name} ${'savedToWishlist'.tr()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showDetails(ProductModel product) {
    final imageUrl = product.images.isNotEmpty
        ? _getImageUrl(product.images.first)
        : '';
    final allImageUrls = product.images
        .map((img) => _getImageUrl(img))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.92,
          child: ProductDetailsScreen(
            productId: product.id,
            productName: product.name,
            productImage: imageUrl,
            productImages: allImageUrls,
            price: product.price,
            description: product.description,
            sizes: product.sizes,
            colors: product.colors,
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _handleSwipe({required Offset offset, required ProductModel product}) {
    final dx = offset.dx;
    final dy = offset.dy;
    final distance = offset.distance;

    if (distance < 50) {
      _resetDrag();
      return;
    }

    if (dy < -100 && dx.abs() < 50) {
      _resetDrag();
      _showDetails(product);
      return;
    }

    if (dx > 100) {
      _addToCart(product);
      setState(() {
        _currentIndex += 1;
        _dragOffset = Offset.zero;
      });
      return;
    }

    if (dx < -100) {
      setState(() {
        _currentIndex += 1;
        _dragOffset = Offset.zero;
      });
      return;
    }

    _resetDrag();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(userProductsProvider);
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;
    final isTablet = screenSize.width > 600;
    final iconSize = min(
      48.0,
      screenSize.width * 0.1,
    ); // Max 48, or 10% of width
    final titleFontSize = min(
      18.0,
      16 * textScaler.scale(1.0) * (isTablet ? 1.1 : 1.0),
    );

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: iconSize,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'failedToLoadProducts'.tr(),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(userProductsProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text('retry'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          data: (products) {
            if (products.isEmpty) {
              return _buildEmptyState();
            }

            final hasMore = _currentIndex < products.length;

            if (!hasMore) {
              return _buildAllExploredState(products);
            }

            return _buildDeck(products);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'noProductsAvailable',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ).tr(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'checkBackLaterForNewArrivals'.tr(),
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(userProductsProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: Text('refresh'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllExploredState(List<ProductModel> products) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'allProductsExplored',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ).tr(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'applyFiltersOrRevisit'.tr(),
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => setState(() {
              _currentIndex = 0;
              _dragOffset = Offset.zero;
            }),
            icon: const Icon(Icons.refresh_rounded),
            label: Text('exploreAgain'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeck(List<ProductModel> products) {
    final visible = products.skip(_currentIndex).take(3).toList();

    // Different layout based on screen orientation
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      return _buildLandscapeDeck(products, visible);
    } else {
      return _buildPortraitDeck(products, visible);
    }
  }

  Widget _buildPortraitDeck(
    List<ProductModel> products,
    List<ProductModel> visible,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleShakeGestures,
        backgroundColor: _shakeEnabled ? AppColors.primary : Colors.grey,
        child: Icon(
          _shakeEnabled ? Icons.vibration : Icons.vibration_outlined,
          color: Colors.white,
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          for (int i = visible.length - 1; i >= 0; i--)
            Positioned(
              top: i * 14.0 + 24,
              child: _SwipeCard(
                product: visible[i],
                depth: i,
                isTop: i == 0,
                dragOffset: i == 0 ? _dragOffset : Offset.zero,
                getImageUrl: _getImageUrl,
                currencyFormatter: currencyFormatter,
                onPanUpdate: i == 0 && !_isPausedByProximity
                    ? (details) => setState(() => _dragOffset += details.delta)
                    : null,
                onPanEnd: i == 0 && !_isPausedByProximity
                    ? (details) => _handleSwipe(
                        offset: _dragOffset,
                        product: visible.first,
                      )
                    : null,
                onDoubleTap: !_isPausedByProximity
                    ? () => _addToWishlist(visible[i])
                    : null,
                onSwipeUp: !_isPausedByProximity
                    ? () => _showDetails(visible[i])
                    : null,
              ),
            ),

          // Proximity pause overlay
          if (_isPausedByProximity)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Browsing Paused',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Phone detected on table',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Move phone away to resume browsing',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLandscapeDeck(
    List<ProductModel> products,
    List<ProductModel> visible,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleShakeGestures,
        backgroundColor: _shakeEnabled ? AppColors.primary : Colors.grey,
        child: Icon(
          _shakeEnabled ? Icons.vibration : Icons.vibration_outlined,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main product (larger) - constrained width
                  Expanded(
                    flex: 2,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      margin: const EdgeInsets.all(8),
                      child: _SwipeCard(
                        product: visible.isNotEmpty
                            ? visible[0]
                            : products[_currentIndex],
                        depth: 0,
                        isTop: true,
                        dragOffset: _dragOffset,
                        getImageUrl: _getImageUrl,
                        currencyFormatter: currencyFormatter,
                        onPanUpdate: !_isPausedByProximity
                            ? (details) =>
                                  setState(() => _dragOffset += details.delta)
                            : null,
                        onPanEnd: !_isPausedByProximity
                            ? (details) => _handleSwipe(
                                offset: _dragOffset,
                                product: visible.isNotEmpty
                                    ? visible[0]
                                    : products[_currentIndex],
                              )
                            : null,
                        onDoubleTap: !_isPausedByProximity
                            ? () => _addToWishlist(
                                visible.isNotEmpty
                                    ? visible[0]
                                    : products[_currentIndex],
                              )
                            : null,
                        onSwipeUp: !_isPausedByProximity
                            ? () => _showDetails(
                                visible.isNotEmpty
                                    ? visible[0]
                                    : products[_currentIndex],
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Next product preview (smaller) - constrained width
                  if (visible.length > 1)
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.35,
                        ),
                        margin: const EdgeInsets.all(8),
                        child: Opacity(
                          opacity: 0.7,
                          child: _SwipeCard(
                            product: visible[1],
                            depth: 1,
                            isTop: false,
                            dragOffset: Offset.zero,
                            getImageUrl: _getImageUrl,
                            currencyFormatter: currencyFormatter,
                            onPanUpdate: null,
                            onPanEnd: null,
                            onDoubleTap: null,
                            onSwipeUp: null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Proximity pause overlay for landscape
            if (_isPausedByProximity)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Landscape Browsing Paused',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Phone detected on table',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwipeCard extends StatelessWidget {
  const _SwipeCard({
    required this.product,
    required this.depth,
    required this.isTop,
    required this.dragOffset,
    required this.getImageUrl,
    required this.currencyFormatter,
    this.onPanUpdate,
    this.onPanEnd,
    this.onDoubleTap,
    this.onSwipeUp,
  });

  final ProductModel product;
  final int depth;
  final bool isTop;
  final Offset dragOffset;
  final String Function(String) getImageUrl;
  final String Function(double) currencyFormatter;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSwipeUp;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width < 600 ? width * 0.92 : width * 0.72;
    final translation = isTop ? dragOffset : Offset.zero;
    final rotation = isTop ? dragOffset.dx * 0.0006 : 0.0;
    final scale = 1 - (depth * 0.04);

    final imageUrl = product.images.isNotEmpty
        ? getImageUrl(product.images.first)
        : '';

    Widget cardContent = Card(
      margin: EdgeInsets.zero,
      elevation: isTop ? 16 : 6,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      shadowColor: Colors.black12,
      child: SizedBox(
        width: cardWidth,
        height: width < 600 ? 650 : 750,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Stack(
            children: [
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: imageUrl.isNotEmpty
                        ? AppCachedImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorWidget: _buildImagePlaceholder(context),
                          )
                        : _buildImagePlaceholder(context),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Text(
                          currencyFormatter(product.price),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        if (product.discount != null &&
                            product.discount! > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${product.discount!.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: product.colors.take(3).map((c) {
                        return Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _getColorFromName(c),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ActionButton(
                          icon: Icons.favorite_border,
                          onTap: onDoubleTap,
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.arrow_forward,
                          onTap: onSwipeUp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Swipe up indicator (always visible, bottom center)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.55),
                      size: 28,
                    ),
                    Text(
                      'swipeUpForDetails'.tr(),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Only the top card should be swipeable
    if (isTop) {
      cardContent = GestureDetector(
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onDoubleTap: onDoubleTap,
        child: cardContent,
      );
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(translation.dx, translation.dy)
        ..rotateZ(rotation)
        ..scale(scale),
      child: cardContent,
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      height: 220,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 80,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final colors = {
      'white': Colors.grey.shade200,
      'black': Colors.black,
      'brown': const Color(0xFF8B4513),
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'sage': const Color(0xFF9DC183),
      'charcoal': Colors.grey.shade700,
      'sand': const Color(0xFFD4A574),
      'navy': Colors.blue.shade900,
      'moss': const Color(0xFF6B8E23),
      'cream': const Color(0xFFFFFDD0),
      'beige': const Color(0xFFF5F5DC),
    };
    return colors[colorName.toLowerCase()] ?? Colors.grey;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}
