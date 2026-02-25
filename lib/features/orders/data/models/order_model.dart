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
    required super.tracking,
  });

  /// Helper to safely cast nested maps from Hive (Map<dynamic, dynamic> -> Map<String, dynamic>)
  static Map<String, dynamic> _safeMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final shippingAddr = _safeMap(json['shippingAddress']);
    final paymentMeth = _safeMap(json['paymentMethod']);

    // Handle userId - can be string or object
    String userId = '';
    final userIdValue = json['userId'];
    if (userIdValue is String) {
      userId = userIdValue;
    } else if (userIdValue is Map) {
      // If it's an object/map, try to get _id field
      userId = userIdValue['_id'] ?? userIdValue['id'] ?? '';
    }

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userId,
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(_safeMap(item)))
              .toList() ??
          [],
      shippingAddress: AddressEntity(
        id: shippingAddr['id'] ?? '',
        fullName: shippingAddr['fullName'] ?? '',
        phone: shippingAddr['phone'] ?? '',
        street: shippingAddr['street'] ?? '',
        city: shippingAddr['city'] ?? '',
        state: shippingAddr['state'] ?? '',
        zipCode: shippingAddr['zipCode'] ?? '',
        country: shippingAddr['country'] ?? '',
      ),
      paymentMethod: PaymentMethodEntity(
        id: paymentMeth['id'] ?? '',
        type: paymentMeth['type'] ?? '',
        last4: paymentMeth['last4'],
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
      tracking:
          (json['tracking'] as List<dynamic>?)?.map((e) {
            final trackingMap = _safeMap(e);
            return TrackingEntity(
              status: trackingMap['status'] ?? '',
              description: trackingMap['description'] ?? '',
              timestamp: DateTime.parse(trackingMap['timestamp']),
              location: trackingMap['location'],
            );
          }).toList() ??
          [],
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
      'tracking': tracking
          .map(
            (t) => {
              'status': t.status,
              'description': t.description,
              'timestamp': t.timestamp.toIso8601String(),
              'location': t.location,
            },
          )
          .toList(),
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
      tracking: entity.tracking,
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
