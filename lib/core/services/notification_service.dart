import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing push notifications
class NotificationService {
  static const String _notificationsEnabledKey = 'notificationsEnabled';

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Enable or disable push notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    // Here you would typically integrate with a push notification service
    // like Firebase Cloud Messaging, OneSignal, etc.
    if (enabled) {
      // Enable push notifications
      print('🔔 Push notifications enabled');
    } else {
      // Disable push notifications
      print('🔕 Push notifications disabled');
    }
  }

  /// Show a notification (for demo purposes)
  void showTestNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This is a test notification!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});