// lib/features/orders/domain/entities/order_entity.dart
class OrderEntity {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  // final AddressEntity shippingAddress;
  // final PaymentMethodEntity paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    // required this.shippingAddress,
    // required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.status,
    this.trackingNumber,
    required this.createdAt,
    this.deliveredAt,
  });
}

class OrderItemEntity {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
}

class TrackingEntity {
  final String status;
  final String description;
  final DateTime timestamp;
  final String? location;

  TrackingEntity({
    required this.status,
    required this.description,
    required this.timestamp,
    this.location,
  });
}