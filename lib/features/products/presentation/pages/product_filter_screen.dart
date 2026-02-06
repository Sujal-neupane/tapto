import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/product_providers.dart';

class ProductFilterScreen extends ConsumerStatefulWidget {
  const ProductFilterScreen({super.key});

  @override
  ConsumerState<ProductFilterScreen> createState() => _ProductFilterScreenState();
}

class _ProductFilterScreenState extends ConsumerState<ProductFilterScreen>
    with TickerProviderStateMixin {
  late SearchFilters _filters;
  RangeValues _priceRange = const RangeValues(0, 1000);
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];
  List<String> _selectedTags = [];

  // Available filter options
  final List<String> _categories = ['Men', 'Women'];
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _colors = ['Black', 'White', 'Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Pink', 'Grey', 'Brown'];
  final List<String> _tags = ['New Arrival', 'Sale', 'Trending', 'Limited Edition', 'Eco-Friendly', 'Premium'];

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _filters = ref.read(searchFiltersProvider);
    _priceRange = RangeValues(
      _filters.minPrice ?? 0,
      _filters.maxPrice ?? 1000,
    );
    _selectedSizes = _filters.tags?.where((tag) => _sizes.contains(tag)).toList() ?? [];
    _selectedColors = _filters.tags?.where((tag) => _colors.contains(tag)).toList() ?? [];
    _selectedTags = _filters.tags?.where((tag) => _tags.contains(tag)).toList() ?? [];

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildContent(),
          _buildApplyButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.close, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'filters'.tr(),
        style: AppTextStyles.heading.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _clearAllFilters,
          child: Text(
            'clearAll'.tr(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Filters Summary
          if (_hasActiveFilters()) _buildActiveFiltersSummary(),

          const SizedBox(height: 24),

          // Category Section
          _buildFilterSection(
            title: 'category'.tr(),
            icon: Icons.category_outlined,
            child: _buildCategoryGrid(),
          ),

          const SizedBox(height: 32),

          // Price Range Section
          _buildFilterSection(
            title: 'priceRange'.tr(),
            icon: Icons.attach_money,
            child: _buildPriceRangeCard(),
          ),

          const SizedBox(height: 32),

          // Size Section
          _buildFilterSection(
            title: 'size'.tr(),
            icon: Icons.straighten,
            child: _buildSizeGrid(),
          ),

          const SizedBox(height: 32),

          // Color Section
          _buildFilterSection(
            title: 'color'.tr(),
            icon: Icons.palette_outlined,
            child: _buildColorGrid(),
          ),

          const SizedBox(height: 32),

          // Tags Section
          _buildFilterSection(
            title: 'tags'.tr(),
            icon: Icons.local_offer_outlined,
            child: _buildTagsGrid(),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _filters.category != null ||
           _priceRange.start > 0 ||
           _priceRange.end < 1000 ||
           _selectedSizes.isNotEmpty ||
           _selectedColors.isNotEmpty ||
           _selectedTags.isNotEmpty;
  }

  Widget _buildActiveFiltersSummary() {
    final activeCount = [
      if (_filters.category != null) 1,
      if (_priceRange.start > 0 || _priceRange.end < 1000) 1,
      _selectedSizes.length,
      _selectedColors.length,
      _selectedTags.length,
    ].fold(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.filter_list,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${activeCount} ${'activeFilters'.tr()}',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearAllFilters,
            icon: Icon(
              Icons.clear,
              color: AppColors.primary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _filters.category == category;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _filters = _filters.copyWith(clearCategory: true);
                  } else {
                    _filters = _filters.copyWith(category: category);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      category == 'Men' ? Icons.man : Icons.woman,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category,
                      style: AppTextStyles.body.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${_priceRange.start.toInt()}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${_priceRange.end.toInt()}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 100,
            activeColor: AppColors.primary,
            inactiveColor: Colors.grey.shade200,
            overlayColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.2)),
            labels: RangeLabels(
              '\$${_priceRange.start.toInt()}',
              '\$${_priceRange.end.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            'priceRangeHint'.tr(),
            style: AppTextStyles.caption?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSizeGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _sizes.map((size) {
          final isSelected = _selectedSizes.contains(size);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedSizes.remove(size);
                } else {
                  _selectedSizes.add(size);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  size,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorGrid() {
    final colorMap = {
      'Black': Colors.black,
      'White': Colors.white,
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Yellow': Colors.yellow,
      'Purple': Colors.purple,
      'Pink': Colors.pink,
      'Grey': Colors.grey,
      'Brown': Colors.brown,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: _colors.map((colorName) {
          final isSelected = _selectedColors.contains(colorName);
          final color = colorMap[colorName] ?? Colors.grey;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedColors.remove(colorName);
                } else {
                  _selectedColors.add(colorName);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagsGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _tags.map((tag) {
          final isSelected = _selectedTags.contains(tag);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedTags.remove(tag);
                } else {
                  _selectedTags.add(tag);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppColors.secondary : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_offer,
                    color: isSelected ? Colors.white : AppColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tag,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ScaleTransition(
          scale: _fabAnimation,
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'applyFilters'.tr(),
                  style: AppTextStyles.button.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_getActiveFilterCount()}',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    return [
      if (_filters.category != null) 1,
      if (_priceRange.start > 0 || _priceRange.end < 1000) 1,
      _selectedSizes.length,
      _selectedColors.length,
      _selectedTags.length,
    ].fold(0, (sum, count) => sum + count);
  }

  void _clearAllFilters() {
    setState(() {
      _filters = const SearchFilters();
      _priceRange = const RangeValues(0, 1000);
      _selectedSizes.clear();
      _selectedColors.clear();
      _selectedTags.clear();
    });
  }

  void _applyFilters() {
    // Combine all selected filters into tags
    final allTags = [..._selectedSizes, ..._selectedColors, ..._selectedTags];

    // Update the provider using the notifier methods
    final notifier = ref.read(searchFiltersProvider.notifier);
    if (_filters.category != null) {
      notifier.setCategory(_filters.category);
    }
    notifier.setPriceRange(
      _priceRange.start == 0 ? null : _priceRange.start,
      _priceRange.end == 1000 ? null : _priceRange.end,
    );
    notifier.setTags(allTags.isEmpty ? null : allTags);

    // Close the filter screen
    Navigator.of(context).pop();
  }
}