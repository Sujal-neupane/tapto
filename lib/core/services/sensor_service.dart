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

/// Types of device orientation
enum DeviceOrientation {
  portrait,
  landscape,
  faceUp,
  faceDown,
}

/// Types of ambient light levels
enum LightLevel {
  dark,      // Low light, suggest dark theme
  normal,    // Normal lighting
  bright,    // Bright light, suggest light theme
}

/// Sensor service for handling device sensors
class SensorService {
  static const double SHAKE_THRESHOLD = 15.0; // m/s²
  static const double DIRECTION_THRESHOLD = 5.0; // m/s²
  static const Duration SHAKE_COOLDOWN = Duration(milliseconds: 500);
  static const double PROXIMITY_THRESHOLD = 2.0; // Acceleration threshold for proximity detection
  static const double LIGHT_DARK_THRESHOLD = 10.0; // Lux threshold for dark mode
  static const double LIGHT_BRIGHT_THRESHOLD = 1000.0; // Lux threshold for bright light

  final StreamController<ShakeDirection> _shakeController = StreamController<ShakeDirection>.broadcast();
  final StreamController<bool> _proximityController = StreamController<bool>.broadcast();
  final StreamController<DeviceOrientation> _orientationController = StreamController<DeviceOrientation>.broadcast();
  final StreamController<LightLevel> _lightLevelController = StreamController<LightLevel>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  DateTime _lastShakeTime = DateTime.now();
  bool _isListening = false;
  bool _isNearFace = false; // Track proximity state
  DeviceOrientation _currentOrientation = DeviceOrientation.portrait;
  LightLevel _currentLightLevel = LightLevel.normal;

  /// Stream of shake directions
  Stream<ShakeDirection> get shakeStream => _shakeController.stream;

  /// Stream of proximity sensor (true = near face, false = far)
  Stream<bool> get proximityStream => _proximityController.stream;

  /// Stream of device orientation changes
  Stream<DeviceOrientation> get orientationStream => _orientationController.stream;

  /// Stream of ambient light level changes
  Stream<LightLevel> get lightLevelStream => _lightLevelController.stream;

  /// Start listening to sensors
  void startListening() {
    if (_isListening) return;

    _isListening = true;
    debugPrint('🎯 SensorService: Starting sensor listening');

    // Listen to accelerometer for shake detection
    _accelerometerSubscription = accelerometerEventStream().listen(_onAccelerometerEvent);

    // Listen to user accelerometer (removes gravity) for better shake detection
    _userAccelerometerSubscription = userAccelerometerEventStream().listen(_onUserAccelerometerEvent);

    // Listen to gyroscope for orientation detection
    _gyroscopeSubscription = gyroscopeEventStream().listen(_onGyroscopeEvent);

    // Listen to magnetometer for compass data
    _magnetometerSubscription = magnetometerEventStream().listen(_onMagnetometerEvent);
  }

  /// Stop listening to sensors
  void stopListening() {
    if (!_isListening) return;

    _isListening = false;
    debugPrint('🎯 SensorService: Stopping sensor listening');

    _accelerometerSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _userAccelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _magnetometerSubscription = null;
  }

  /// Handle accelerometer events for shake detection and proximity
  void _onAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    // Detect device orientation
    _detectOrientation(event);

    // Calculate acceleration magnitude (excluding gravity)
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z) - 9.8;

    // Proximity detection: when phone is near face, acceleration is very low
    // and device is likely in a stable position (like during a call)
    final isNearFace = magnitude < PROXIMITY_THRESHOLD &&
                      event.z.abs() > 8.0; // Z-axis shows gravity when face-up

    if (isNearFace != _isNearFace) {
      _isNearFace = isNearFace;
      _proximityController.add(_isNearFace);
      debugPrint('📱 Proximity: ${_isNearFace ? "NEAR FACE" : "FAR FROM FACE"}');
    }

    // Shake detection with cooldown
    if (now.difference(_lastShakeTime) < SHAKE_COOLDOWN) {
      return;
    }

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

  /// Handle gyroscope events for orientation detection
  void _onGyroscopeEvent(GyroscopeEvent event) {
    // Gyroscope gives rotational velocity, we need to integrate this over time
    // For simplicity, we'll use accelerometer data for orientation detection
    // A full implementation would combine accelerometer, gyroscope, and magnetometer
  }

  /// Handle magnetometer events for compass data
  void _onMagnetometerEvent(MagnetometerEvent event) {
    // Calculate compass heading for potential location-based features
    // This could be used for AR product visualization or store direction features
    final heading = atan2(event.y, event.x) * (180 / pi);
    final normalizedHeading = (heading + 360) % 360;

    // Store heading for potential use in location-based features
    // For now, we don't emit this as a stream since we don't have UI for it yet
  }

  /// Detect device orientation from accelerometer data
  void _detectOrientation(AccelerometerEvent event) {
    // Simple orientation detection based on accelerometer
    // X > |Y| and |Z| ≈ 9.8 means portrait
    // |Y| > |X| and |Z| ≈ 9.8 means landscape

    final absX = event.x.abs();
    final absY = event.y.abs();
    final absZ = event.z.abs();

    DeviceOrientation newOrientation;

    if (absZ > 8.0) { // Device is roughly flat
      if (absX > absY) {
        newOrientation = DeviceOrientation.landscape;
      } else {
        newOrientation = DeviceOrientation.portrait;
      }
    } else if (event.z > 5.0) {
      newOrientation = DeviceOrientation.faceUp;
    } else if (event.z < -5.0) {
      newOrientation = DeviceOrientation.faceDown;
    } else {
      newOrientation = DeviceOrientation.portrait; // Default
    }

    if (newOrientation != _currentOrientation) {
      _currentOrientation = newOrientation;
      _orientationController.add(_currentOrientation);
      debugPrint('📱 Orientation: $_currentOrientation');
    }
  }

  /// Dispose of resources
  void dispose() {
    stopListening();
    _shakeController.close();
    _proximityController.close();
    _orientationController.close();
    _lightLevelController.close();
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