import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.images,
    required super.category,
    super.subcategory,
    required super.stock,
    required super.isActive,
    super.discount,
    required super.sizes,
    required super.colors,
    required super.tags,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      stock: json['stock'] ?? 0,
      isActive: json['isActive'] ?? true,
      discount: (json['discount'] as num?)?.toDouble(),
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'subcategory': subcategory,
      'stock': stock,
      'isActive': isActive,
      'sizes': sizes,
      'colors': colors,
      'discount': discount,
      'tags': tags,
      'createdBy': createdBy,
    };
  }
}