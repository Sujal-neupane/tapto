class TrackingEntity {
  final String status;
  final String description;
  final DateTime timestamp;
  final String? location;
  final Map<String, dynamic>? metadata;

  TrackingEntity({
    required this.status,
    required this.description,
    required this.timestamp,
    this.location,
    this.metadata,
  });
}

class LiveTrackingEntity {
  final String orderId;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final double? currentLat;
  final double? currentLng;
    final String? currentLocationAddress;
    final double? destinationLat;
    final double? destinationLng;
  final String? estimatedTime;
  final String? distanceRemaining;
  final String? cancellationReason;
  final List<TrackingEntity> timeline;

  LiveTrackingEntity({
    required this.orderId,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    this.currentLat,
    this.currentLng,
    this.currentLocationAddress,
    this.destinationLat,
    this.destinationLng,
    this.estimatedTime,
    this.distanceRemaining,
    this.cancellationReason,
    required this.timeline,
  });
}