class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? size;
  final String? color;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.size,
    required this.color,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? size,
    String? color,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}