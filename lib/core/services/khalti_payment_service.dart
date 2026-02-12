import 'package:flutter/material.dart';

class KhaltiPaymentService {
  static const String _publicKey = 'test_public_key_dc74e0fd57cb46cd93832aee0a507256'; // Khalti test key

  static Future<void> initiatePayment({
    required BuildContext context,
    required double amount,
    required String productName,
    required String productId,
    required Function(String pidx) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      // For demo purposes, simulate payment success immediately
      // In production, you would integrate with Khalti's payment API
      await Future.delayed(const Duration(seconds: 1));

      // Show a message that payment was successful
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khalti payment successful (demo mode)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Call success callback
      onSuccess('demo_khalti_pidx_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      onError('Payment initialization failed: $e');
    }
  }

  // Verify payment with backend
  static Future<bool> verifyPayment(String pidx) async {
    try {
      // This should be implemented to verify with your backend
      // which will call Khalti's verification API
      // For now, return true assuming verification is done on backend
      return true;
    } catch (e) {
      return false;
    }
  }
}