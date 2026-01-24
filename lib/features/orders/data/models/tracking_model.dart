import 'package:tapto/features/orders/domain/enitites/tracking_entity.dart';

class TrackingModel extends TrackingEntity {
  TrackingModel({
    required super.status,
    required super.description,
    required super.timestamp,
    super.location,
    super.metadata,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      location: json['location'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'metadata': metadata,
    };
  }
}

class LiveTrackingModel extends LiveTrackingEntity {
  LiveTrackingModel({
    required super.orderId,
    super.deliveryPersonName,
    super.deliveryPersonPhone,
    super.currentLat,
    super.currentLng,
    super.destinationLat,
    super.destinationLng,
    super.estimatedTime,
    super.distanceRemaining,
    required super.timeline,
  });

  factory LiveTrackingModel.fromJson(Map<String, dynamic> json) {
    return LiveTrackingModel(
      orderId: json['orderId'] ?? '',
      deliveryPersonName: json['deliveryPerson']?['name'],
      deliveryPersonPhone: json['deliveryPerson']?['phone'],
      currentLat: json['currentLocation']?['lat']?.toDouble(),
      currentLng: json['currentLocation']?['lng']?.toDouble(),
      destinationLat: json['destination']?['lat']?.toDouble(),
      destinationLng: json['destination']?['lng']?.toDouble(),
      estimatedTime: json['estimatedTime'],
      distanceRemaining: json['distanceRemaining'],
      timeline: (json['timeline'] as List?)
              ?.map((item) => TrackingModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'deliveryPerson': deliveryPersonName != null
          ? {
              'name': deliveryPersonName,
              'phone': deliveryPersonPhone,
            }
          : null,
      'currentLocation': currentLat != null && currentLng != null
          ? {
              'lat': currentLat,
              'lng': currentLng,
            }
          : null,
      'destination': destinationLat != null && destinationLng != null
          ? {
              'lat': destinationLat,
              'lng': destinationLng,
            }
          : null,
      'estimatedTime': estimatedTime,
      'distanceRemaining': distanceRemaining,
      'timeline': timeline.map((t) => (t as TrackingModel).toJson()).toList(),
    };
  }
}
