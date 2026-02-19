import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();


  static Future<bool> isBiometricAvailable() async {
    try {
      // Only return true if biometrics are actually available and enrolled
      // On simulators, this will return false
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      if (!canAuthenticateWithBiometrics) return false;
      
      // Check if there are any enrolled biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async{
    try {
      return await _localAuth.getAvailableBiometrics();
    }on PlatformException {
      return [];
    }
  }

  static Future<bool> authenticate({
    String reason = 'Please authenticate to proceed with payment',
    String? localizedReason,
  }) async{
    try{
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason ?? reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    }
  }



  static Future<bool> canCheckBiometrics() async {
    try{
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }
}