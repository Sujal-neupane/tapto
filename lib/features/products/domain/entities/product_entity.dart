class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String category; // Men or Women
  final String? subcategory; // T-Shirts, Jeans, etc.
  final int stock;
  final bool isActive;
  final List<String> sizes;
  final List<String> colors;
  final double? discount;
  final List<String> tags;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    this.subcategory,
    required this.stock,
    required this.isActive,
    required this.sizes,
    required this.colors,
    this.discount,
    required this.tags,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}

