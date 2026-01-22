// lib/features/orders/data/models/order_model.dart
import '../../domain/entities/order_entity.dart';
// import '../../../addresses/data/models/address_model.dart';
// import '../../../payments/data/models/payment_method_model.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    // required super.shippingAddress,
    // required super.paymentMethod,
    required super.subtotal,
    required super.shippingFee,
    required super.tax,
    required super.total,
    required super.status,
    super.trackingNumber,
    required super.createdAt,
    super.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      // shippingAddress: AddressModel.fromJson(json['shippingAddress']),
      // paymentMethod: PaymentMethodModel.fromJson(json['paymentMethod']),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shippingFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: _statusFromString(json['status']),
      trackingNumber: json['trackingNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      // 'shippingAddress': (shippingAddress as AddressModel).toJson(),
      // 'paymentMethod': (paymentMethod as PaymentMethodModel).toJson(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'total': total,
      'status': status.name,
    };
  }

  static OrderStatus _statusFromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
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
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
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

class TrackingModel extends TrackingEntity {
  TrackingModel({
    required super.status,
    required super.description,
    required super.timestamp,
    super.location,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      status: json['status'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
    );
  }
}