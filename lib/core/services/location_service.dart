import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Location service for handling device location and address services
class LocationService {
  static const Duration LOCATION_TIMEOUT = Duration(seconds: 10);

  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  final StreamController<LocationAccuracy> _accuracyController = StreamController<LocationAccuracy>.broadcast();

  StreamSubscription<Position>? _positionSubscription;

  /// Stream of position updates
  Stream<Position> get positionStream => _positionController.stream;

  /// Stream of accuracy changes
  Stream<LocationAccuracy> get accuracyStream => _accuracyController.stream;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current position
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout,
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout ?? LOCATION_TIMEOUT,
      );
    } catch (e) {
      debugPrint('❌ Location error: $e');
      rethrow;
    }
  }

  /// Start listening to position updates
  void startPositionUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    stopPositionUpdates(); // Stop any existing subscription

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).listen(
      (Position position) {
        _positionController.add(position);
        debugPrint('📍 Position update: ${position.latitude}, ${position.longitude}');
      },
      onError: (error) {
        debugPrint('❌ Position stream error: $error');
      },
    );
  }

  /// Stop listening to position updates
  void stopPositionUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('❌ Last known position error: $e');
      return null;
    }
  }

  /// Calculate distance between two positions
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Dispose of resources
  void dispose() {
    stopPositionUpdates();
    _positionController.close();
    _accuracyController.close();
  }

  /// Get address from coordinates (reverse geocoding)
  /// Note: This would require a geocoding service like Google Maps API
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    // This is a placeholder - in production, you'd use a geocoding service
    // For now, return formatted coordinates
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Get coordinates from address (forward geocoding)
  /// Note: This would require a geocoding service
  Future<Position> getCoordinatesFromAddress(String address) async {
    // This is a placeholder - in production, you'd use a geocoding service
    throw UnimplementedError('Forward geocoding requires external service integration');
  }
}