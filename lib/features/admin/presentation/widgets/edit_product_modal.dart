import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/core/services/storage/storage_provider.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/app/theme/app_spacing.dart';
import 'package:tapto/core/widgets/cached_image.dart';
import 'package:tapto/features/products/data/models/product_model.dart';
import 'package:tapto/features/products/presentation/providers/product_providers.dart';

class EditProductModal extends ConsumerStatefulWidget {
  final ProductModel product;

  const EditProductModal({super.key, required this.product});

  @override
  ConsumerState<EditProductModal> createState() => _EditProductModalState();
}

class _EditProductModalState extends ConsumerState<EditProductModal> {
  static const _menCategories = [
    'T-Shirts',
    'Shirts',
    'Jeans',
    'Trousers',
    'Shoes',
    'Formal Wear',
    'Jackets',
    'Accessories',
  ];
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _discountController;
  late TextEditingController _sizesController;
  late TextEditingController _colorsController;

  late String _fashionType;
  late String _category;

  List<String> _existingImages = [];
  final List<String> _imagesToRemove = [];
  final List<XFile> _newImages = [];
  bool _isLoading = false;

  static const _womenCategories = [
    'Dresses',
    'Tops',
    'Jeans',
    'Skirts',
    'Heels',
    'Flats',
    'Bags',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _discountController = TextEditingController(
      text: widget.product.discount?.toString() ?? '0',
    );
    _sizesController = TextEditingController(
      text: widget.product.sizes.join(', '),
    );
    _colorsController = TextEditingController(
      text: widget.product.colors.join(', '),
    );

    _fashionType = _inferFashionType(widget.product.category);
    _category = widget.product.subcategory ?? widget.product.category;
    _existingImages = List.from(widget.product.images);
  }

  String _inferFashionType(String category) {
    // If category is "Men" or "Women", use it directly
    if (category.toLowerCase() == 'men' || category.toLowerCase() == 'women') {
      return category.toLowerCase();
    }
    // If it's a subcategory, default to men
    return 'men';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      _fashionType == 'men' ? _menCategories : _womenCategories;

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    return '${ApiEndpoints.baseUrl}$imagePath';
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images));
    }
  }

  void _removeExistingImage(String image) {
    setState(() {
      _existingImages.remove(image);
      _imagesToRemove.add(image);
    });
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tokenStorage = ref.read(tokenStorageServiceProvider);
      final token = tokenStorage.getToken();

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'discount': double.tryParse(_discountController.text) ?? 0,
        'fashionType': _fashionType,
        'category': _category,
        'sizes': _sizesController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'colors': _colorsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'existingImages': _existingImages,
        'imagesToRemove': _imagesToRemove,
      });

      // Add new images
      for (var i = 0; i < _newImages.length; i++) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(_newImages[i].path)),
        );
      }

      final response = await dio.put(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminProductById(widget.product.id)}',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        ref.invalidate(adminProductsProvider);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagesSection(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildBasicInfoSection(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildCategorySection(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildVariantsSection(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSubmitButton(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
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
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'Edit Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Existing Images
        if (_existingImages.isNotEmpty) ...[
          const Text('Current Images:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImages.length,
              itemBuilder: (context, index) {
                final image = _existingImages[index];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppCachedImage(
                          imageUrl: _getImageUrl(image),
                          fit: BoxFit.cover,
                          errorWidget: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(image),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // New Images
        if (_newImages.isNotEmpty) ...[
          const Text('New Images:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_newImages[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Add Image Button
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Images'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        if (_existingImages.isEmpty && _newImages.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'At least one image is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration('Product Name', Icons.shopping_bag),
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _descriptionController,
          decoration: _inputDecoration('Description', Icons.description),
          maxLines: 3,
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: _inputDecoration('Price', Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v ?? '') == null ? 'Invalid' : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _stockController,
                decoration: _inputDecoration('Stock', Icons.inventory),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Invalid' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _discountController,
          decoration: _inputDecoration('Discount %', Icons.discount),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),

        // Fashion Type Toggle
        Row(
          children: [
            _buildToggleButton('Men', 'men'),
            const SizedBox(width: 12),
            _buildToggleButton('Women', 'women'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Category Dropdown
        DropdownButtonFormField<String>(
          initialValue: _categories.contains(_category) ? _category : null,
          decoration: _inputDecoration('Category', Icons.category),
          items: _categories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (v) => setState(() => _category = v ?? ''),
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Variants',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _sizesController,
          decoration: _inputDecoration(
            'Sizes (comma separated)',
            Icons.straighten,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _colorsController,
          decoration: _inputDecoration(
            'Colors (comma separated)',
            Icons.palette,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_existingImages.isEmpty && _newImages.isEmpty)
            ? null
            : _updateProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Update Product',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    final isSelected = _fashionType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _fashionType = value;
          _category = '';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
