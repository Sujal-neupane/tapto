import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/presentation/pages/product_details_screen.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class _Product {
  const _Product({
    required this.title,
    required this.brand,
    required this.price,
    required this.subtitle,
    required this.material,
    required this.care,
    required this.colors,
    required this.sizes,
    required this.image,
  });

  final String title;
  final String brand;
  final double price;
  final String subtitle;
  final String material;
  final List<String> care;
  final List<String> colors;
  final List<String> sizes;
  final String image;
}

class HomeSwipeScreen extends ConsumerStatefulWidget {
  const HomeSwipeScreen({super.key});

  @override
  ConsumerState<HomeSwipeScreen> createState() => _HomeSwipeScreenState();
}

class _HomeSwipeScreenState extends ConsumerState<HomeSwipeScreen>
    with SingleTickerProviderStateMixin {
  final List<_Product> _products = const [
    _Product(
      title: 'Premium Sneakers',
      brand: 'StepUp',
      price: 149.99,
      subtitle:
          'High-performance sneakers combining style and comfort with breathable mesh.',
      material: 'Mesh upper with rubber sole',
      care: [
        'Wipe clean with damp cloth',
        'Air dry only',
        'Do not machine wash',
        'Store in cool, dry place',
      ],
      colors: ['White', 'Black', 'Brown'],
      sizes: ['6', '7', '8', '9', '10', '11', '12'],
      image: 'https://images.unsplash.com/photo-1549298916-b41d501d3772',
    ),
    _Product(
      title: 'Leather Oxfords',
      brand: 'Northlane',
      price: 189.50,
      subtitle:
          'Formal leather shoes with cushioned insole and breathable lining for all-day wear.',
      material: 'Full-grain leather upper, rubber outsole',
      care: [
        'Condition leather monthly',
        'Avoid direct sunlight',
        'Use shoe trees',
      ],
      colors: ['Brown', 'Black'],
      sizes: ['7', '8', '9', '10', '11'],
      image: 'https://images.unsplash.com/photo-1515548212436-0f2d5c9c5a18',
    ),
    _Product(
      title: 'Daylight Hoodie',
      brand: 'Aurora',
      price: 89.00,
      subtitle:
          'Lightweight fleece hoodie with oversized hood and kangaroo pocket for everyday comfort.',
      material: 'Organic cotton blend fleece',
      care: ['Machine wash cold', 'Tumble dry low', 'Do not bleach'],
      colors: ['Sage', 'Charcoal', 'Sand'],
      sizes: ['S', 'M', 'L', 'XL'],
      image: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c',
    ),
    _Product(
      title: 'Minimal Tee',
      brand: 'Lineal',
      price: 39.90,
      subtitle:
          'Breathable everyday tee with relaxed fit and subtle neckline taping.',
      material: 'Pima cotton jersey',
      care: ['Machine wash gentle', 'Dry flat', 'Warm iron if needed'],
      colors: ['White', 'Navy', 'Moss'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      image: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
    ),
  ];

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  late AnimationController _animationController;

  bool get _hasMore => _currentIndex < _products.length;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetDrag() {
    setState(() => _dragOffset = Offset.zero);
  }

  void _addToCart(_Product product) {
    ref.read(cartViewModelProvider.notifier).addItem(
      CartItemModel(
        productId: product.title, // Use a real productId if available
        productName: product.title,
        productImage: product.image,
        price: product.price,
        quantity: 1,
        size: product.sizes.isNotEmpty ? product.sizes.first : '',
        color: product.colors.isNotEmpty ? product.colors.first : '',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart ✓'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _addToWishlist(_Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} saved to wishlist ♡'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _showDetails(_Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
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
            productId: product.title,
            productName: product.title,
            productImage: product.image,
            price: product.price,
            description: product.subtitle,
            sizes: product.sizes,
            colors: product.colors,
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _handleSwipe({required Offset offset, required _Product product}) {
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
      ),
      child: SafeArea(
        child: _hasMore
            ? _buildDeck()
            : Center(
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
                      'All products explored!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Apply filters or revisit products',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _currentIndex = 0;
                        _dragOffset = Offset.zero;
                      }),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Explore Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDeck() {
    final visible = _products.skip(_currentIndex).take(3).toList();
    return Stack(
      alignment: Alignment.topCenter, // Move cards up
      clipBehavior: Clip.none,
      children: [
        for (int i = visible.length - 1; i >= 0; i--)
          Positioned(
            top: i * 14.0 + 24, // Add top offset (24px looks good)
            child: _SwipeCard(
              product: visible[i],
              depth: i,
              isTop: i == 0,
              dragOffset: i == 0 ? _dragOffset : Offset.zero,
              onPanUpdate: i == 0
                  ? (details) => setState(() => _dragOffset += details.delta)
                  : null,
              onPanEnd: i == 0
                  ? (details) => _handleSwipe(
                        offset: _dragOffset,
                        product: visible.first,
                      )
                  : null,
              onDoubleTap: () => _addToWishlist(visible[i]),
              onSwipeUp: () => _showDetails(visible[i]),
            ),
          ),
      ],
    );
  }
}

class _SwipeCard extends StatelessWidget {
  const _SwipeCard({
    required this.product,
    required this.depth,
    required this.isTop,
    required this.dragOffset,
    this.onPanUpdate,
    this.onPanEnd,
    this.onDoubleTap,
    this.onSwipeUp,
  });

  final _Product product;
  final int depth;
  final bool isTop;
  final Offset dragOffset;
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

    Widget cardContent = Card(
      margin: EdgeInsets.zero,
      elevation: isTop ? 16 : 6,
      color: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      shadowColor: Colors.black12,
      child: SizedBox(
        width: cardWidth,
        height: width < 600 ? 650 : 750, // Increased height for better fill
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
                    child: Image.network(
                      product.image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.brand.toUpperCase(),
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
                    product.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: product.colors.take(3).map((c) {
                      final colors = {
                        'White': Colors.grey.shade200,
                        'Black': Colors.black,
                        'Brown': const Color(0xFF8B4513),
                        'Sage': const Color(0xFF9DC183),
                        'Charcoal': Colors.grey.shade700,
                        'Sand': const Color(0xFFD4A574),
                        'Navy': Colors.blue.shade900,
                        'Moss': const Color(0xFF6B8E23),
                      };
                      return Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: colors[c] ?? Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  Row(
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
                    Icon(Icons.keyboard_arrow_up,
                        color: Colors.grey.shade500, size: 28),
                    Text(
                      'Swipe up for details',
                      style: TextStyle(
                        color: Colors.grey.shade600,
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
        // Optionally, you can use onVerticalDragEnd for swipe up, but your logic is in onPanEnd
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}