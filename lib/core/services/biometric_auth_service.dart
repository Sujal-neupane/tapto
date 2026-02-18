import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();


  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
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