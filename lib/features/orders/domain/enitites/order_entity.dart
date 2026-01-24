class OrderEntity {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final AddressEntity shippingAddress;
  final PaymentMethodEntity paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? cancellationReason;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.status,
    this.trackingNumber,
    required this.createdAt,
    this.deliveredAt,
    this.cancellationReason,
  });

  double get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
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

  double get totalPrice => quantity * price;
}

class AddressEntity {
  final String id;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  AddressEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });
}

class PaymentMethodEntity {
  final String id;
  final String type;
  final String? last4;

  PaymentMethodEntity({
    required this.id,
    required this.type,
    this.last4,
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