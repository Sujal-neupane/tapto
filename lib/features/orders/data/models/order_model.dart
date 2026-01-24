import 'package:tapto/features/orders/domain/enitites/order_entity.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.shippingAddress,
    required super.paymentMethod,
    required super.subtotal,
    required super.shippingFee,
    required super.tax,
    required super.total,
    required super.status,
    super.trackingNumber,
    required super.createdAt,
    super.deliveredAt,
    super.cancellationReason,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      shippingAddress: AddressEntity(
        id: json['shippingAddress']?['id'] ?? '',
        fullName: json['shippingAddress']?['fullName'] ?? '',
        phone: json['shippingAddress']?['phone'] ?? '',
        street: json['shippingAddress']?['street'] ?? '',
        city: json['shippingAddress']?['city'] ?? '',
        state: json['shippingAddress']?['state'] ?? '',
        zipCode: json['shippingAddress']?['zipCode'] ?? '',
        country: json['shippingAddress']?['country'] ?? '',
      ),
      paymentMethod: PaymentMethodEntity(
        id: json['paymentMethod']?['id'] ?? '',
        type: json['paymentMethod']?['type'] ?? '',
        last4: json['paymentMethod']?['last4'],
      ),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: _statusFromString(json['status'] ?? 'pending'),
      trackingNumber: json['trackingNumber'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      cancellationReason: json['cancellationReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'shippingAddress': {
        'id': shippingAddress.id,
        'fullName': shippingAddress.fullName,
        'phone': shippingAddress.phone,
        'street': shippingAddress.street,
        'city': shippingAddress.city,
        'state': shippingAddress.state,
        'zipCode': shippingAddress.zipCode,
        'country': shippingAddress.country,
      },
      'paymentMethod': {
        'id': paymentMethod.id,
        'type': paymentMethod.type,
        'last4': paymentMethod.last4,
      },
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'total': total,
      'status': status.name,
    };
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      items: entity.items,
      shippingAddress: entity.shippingAddress,
      paymentMethod: entity.paymentMethod,
      subtotal: entity.subtotal,
      shippingFee: entity.shippingFee,
      tax: entity.tax,
      total: entity.total,
      status: entity.status,
      trackingNumber: entity.trackingNumber,
      createdAt: entity.createdAt,
      deliveredAt: entity.deliveredAt,
      cancellationReason: entity.cancellationReason,
    );
  }

  OrderEntity toEntity() => this;

  static OrderStatus _statusFromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderItemModel extends OrderItemEntity {
  OrderItemModel({
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
    };
  }
}
