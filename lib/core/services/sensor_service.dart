import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

/// Types of shake gestures
enum ShakeDirection {
  left,
  right,
  none,
}

/// Sensor service for handling device sensors
class SensorService {
  static const double SHAKE_THRESHOLD = 15.0; // m/s²
  static const double DIRECTION_THRESHOLD = 5.0; // m/s²
  static const Duration SHAKE_COOLDOWN = Duration(milliseconds: 500);

  final StreamController<ShakeDirection> _shakeController = StreamController<ShakeDirection>.broadcast();
  final StreamController<bool> _proximityController = StreamController<bool>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;

  DateTime _lastShakeTime = DateTime.now();
  bool _isListening = false;

  /// Stream of shake directions
  Stream<ShakeDirection> get shakeStream => _shakeController.stream;

  /// Stream of proximity sensor (true = near, false = far)
  Stream<bool> get proximityStream => _proximityController.stream;

  /// Start listening to sensors
  void startListening() {
    if (_isListening) return;

    _isListening = true;
    debugPrint('🎯 SensorService: Starting sensor listening');

    // Listen to accelerometer for shake detection
    _accelerometerSubscription = accelerometerEventStream().listen(_onAccelerometerEvent);

    // Listen to user accelerometer (removes gravity) for better shake detection
    _userAccelerometerSubscription = userAccelerometerEventStream().listen(_onUserAccelerometerEvent);
  }

  /// Stop listening to sensors
  void stopListening() {
    if (!_isListening) return;

    _isListening = false;
    debugPrint('🎯 SensorService: Stopping sensor listening');

    _accelerometerSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _userAccelerometerSubscription = null;
  }

  /// Handle accelerometer events for shake detection
  void _onAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    // Check cooldown
    if (now.difference(_lastShakeTime) < SHAKE_COOLDOWN) {
      return;
    }

    // Calculate acceleration magnitude (excluding gravity)
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z) - 9.8;

    // Check if it's a shake
    if (magnitude > SHAKE_THRESHOLD) {
      _lastShakeTime = now;

      // Determine shake direction based on X-axis
      ShakeDirection direction;
      if (event.x > DIRECTION_THRESHOLD) {
        direction = ShakeDirection.right;
        debugPrint('🎯 Shake detected: RIGHT (x: ${event.x})');
      } else if (event.x < -DIRECTION_THRESHOLD) {
        direction = ShakeDirection.left;
        debugPrint('🎯 Shake detected: LEFT (x: ${event.x})');
      } else {
        direction = ShakeDirection.none;
        debugPrint('🎯 Shake detected: NONE (x: ${event.x})');
      }

      _shakeController.add(direction);
    }
  }

  /// Handle user accelerometer events (gravity removed)
  void _onUserAccelerometerEvent(UserAccelerometerEvent event) {
    // This provides cleaner data for shake detection
    // We can use this as a backup or for more precise detection
  }

  /// Dispose of resources
  void dispose() {
    stopListening();
    _shakeController.close();
    _proximityController.close();
  }

  /// Check if sensors are available
  Future<bool> areSensorsAvailable() async {
    try {
      // Try to listen briefly to check availability
      final completer = Completer<bool>();
      late StreamSubscription subscription;

      subscription = accelerometerEventStream().listen((event) {
        subscription.cancel();
        completer.complete(true);
      });

      // Timeout after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.complete(false);
        }
      });

      return completer.future;
    } catch (e) {
      debugPrint('🎯 Sensor availability check failed: $e');
      return false;
    }
  }
}