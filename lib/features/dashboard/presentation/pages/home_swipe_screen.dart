import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

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

class HomeSwipeScreen extends StatefulWidget {
  const HomeSwipeScreen({super.key});

  @override
  State<HomeSwipeScreen> createState() => _HomeSwipeScreenState();
}

class _HomeSwipeScreenState extends State<HomeSwipeScreen>
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart ✓'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _addToWishlist(_Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} saved to wishlist ♡'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showDetails(_Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.5,
          initialChildSize: 0.85,
          builder: (context, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.brand,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      product.title,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionLabel(title: 'Description'),
                    Text(
                      product.subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionLabel(title: 'Material & Care'),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(label: 'Material', value: product.material),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      label: 'Care',
                      value: product.care.join('\n'),
                      alignTop: true,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionLabel(title: 'Colors'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: product.colors
                          .map((c) => _ChoiceChip(label: c))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionLabel(title: 'Sizes'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: product.sizes
                          .map((s) => _ChoiceChip(label: s))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _addToWishlist(product),
                          icon: const Icon(Icons.favorite_border_rounded),
                          label: const Text('Wishlist'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _addToCart(product),
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            );
          },
        );
      },
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
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        for (int i = visible.length - 1; i >= 0; i--)
          Positioned(
            bottom: i * 14.0,
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
    final cardWidth = width < 600 ? width * 0.88 : width * 0.72;
    final translation = isTop ? dragOffset : Offset.zero;
    final rotation = isTop ? dragOffset.dx * 0.0006 : 0.0;
    final scale = 1 - (depth * 0.04);

    final card = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(translation.dx, translation.dy)
        ..rotateZ(rotation)
        ..scale(scale),
      child: GestureDetector(
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onDoubleTap: onDoubleTap,
        onLongPressUp: onSwipeUp,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: isTop ? 12 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: SizedBox(
            width: cardWidth,
            height: width < 600 ? 600 : 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.08),
                                AppColors.primary.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 100,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black26, Colors.transparent],
                            ),
                          ),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  product.brand.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                child: Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isTop)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Opacity(
                            opacity: 0.7,
                            child: Center(
                              child: Text(
                                '↑ Swipe up for details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              product.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.4,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 6,
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
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors[c] ?? Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (isTop)
                              Row(
                                children: [
                                  _SwipeIndicator(
                                    icon: Icons.favorite_border,
                                    label: '♡',
                                    onTap: onDoubleTap,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  _SwipeIndicator(
                                    icon: Icons.arrow_forward,
                                    label: '→',
                                    onTap: onSwipeUp,
                                  ),
                                ],
                              ),
                          ],
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
    );

    return card;
  }
}

class _SwipeIndicator extends StatelessWidget {
  const _SwipeIndicator({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
          color: Colors.grey.shade50,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.alignTop = false,
  });

  final String label;
  final String value;
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: alignTop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(value, style: const TextStyle(height: 1.4))),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        color: Colors.grey.shade50,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
