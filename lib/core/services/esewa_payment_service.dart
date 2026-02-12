import 'package:flutter/material.dart';

class ESewaPaymentService {
  static const String _clientId = 'EPAYTEST'; // eSewa test merchant code
  static const String _secretId = '8gBm/:&EnhH.1/q'; // eSewa test secret

  static Future<void> initiatePayment({
    required BuildContext context,
    required double amount,
    required String productName,
    required String productId,
    required Function(String refId) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      // For demo purposes, simulate payment success immediately
      // In production, you would integrate with eSewa's payment API
      await Future.delayed(const Duration(seconds: 1));

      // Show a message that payment was successful
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('eSewa payment successful (demo mode)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Call success callback
      onSuccess('demo_esewa_ref_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      onError('Payment initialization failed: $e');
    }
  }

  // Verify payment with backend
  static Future<bool> verifyPayment(String refId) async {
    try {
      // This should be implemented to verify with your backend
      // which will call eSewa's verification API
      // For now, return true assuming verification is done on backend
      return true;
    } catch (e) {
      return false;
    }
  }
}