import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import '../widgets/product_details/product_image_gallery.dart';
import '../widgets/product_details/compact_app_bar_button.dart';
import '../widgets/product_details/product_header.dart';
import '../widgets/product_details/product_description.dart';
import '../widgets/product_details/size_selector.dart';
import '../widgets/product_details/color_selector.dart';
import '../widgets/product_details/bottom_cart_bar.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final List<String> productImages;
  final double price;
  final String description;
  final List<String> sizes;
  final List<String> colors;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    this.productImages = const [],
    required this.price,
    required this.description,
    required this.sizes,
    required this.colors,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  String? selectedSize;
  String? selectedColor;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<String> get _allImages {
    if (widget.productImages.isNotEmpty) {
      return widget.productImages;
    }
    return widget.productImage.isNotEmpty ? [widget.productImage] : [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String Function(double) get currencyFormatter =>
      ref.watch(currencyFormatterProvider);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;
    final isTablet = screenSize.width > 600;
    final padding = (screenSize.width * 0.05).toDouble(); // 5% of width
    final titleFontSize = min(
      20.0,
      18 * textScaler.scale(1.0) * (isTablet ? 1.1 : 1.0),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Compact App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 70,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: padding * 0.6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CompactAppBarButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'productDetails'.tr(),
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212529),
                          ),
                        ),
                        CompactAppBarButton(
                          icon: Icons.favorite_border_rounded,
                          onPressed: () {},
                          iconColor: const Color(0xFFFF4757),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Image Gallery
              SliverToBoxAdapter(child: ProductImageGallery(images: _allImages)),

              // Product Details
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductHeader(
                            productName: widget.productName,
                            price: widget.price,
                          ),
                          const SizedBox(height: 24),
                          ProductDescription(description: widget.description),
                          const SizedBox(height: 28),
                          SizeSelector(
                            sizes: widget.sizes,
                            selectedSize: selectedSize,
                            onSizeSelected: (size) => setState(() => selectedSize = size),
                          ),
                          const SizedBox(height: 28),
                          ColorSelector(
                            colors: widget.colors,
                            selectedColor: selectedColor,
                            onColorSelected: (color) => setState(() => selectedColor = color),
                          ),
                          const SizedBox(height: 140), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom Add to Cart Bar
          BottomCartBar(
            productId: widget.productId,
            productName: widget.productName,
            productImage: widget.productImage,
            price: widget.price,
            selectedSize: selectedSize,
            selectedColor: selectedColor,
            onItemAdded: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
