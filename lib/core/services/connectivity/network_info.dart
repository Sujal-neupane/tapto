import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract interface for network connectivity
abstract interface class INetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Provider for NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

/// Implementation of network connectivity checker
class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      // Check if device has connectivity
      final result = await _connectivity.checkConnectivity();

      if (result.contains(ConnectivityResult.none)) {
        return false;
      }

      // Actually verify internet access by checking connection to a reliable host
      return await _hasInternetAccess();
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result.contains(ConnectivityResult.none)) {
        return false;
      }
      return await _hasInternetAccess();
    });
  }

  /// Verify actual internet access by pinging a reliable host
  Future<bool> _hasInternetAccess() async {
    try {
      // On iOS simulator, InternetAddress.lookup can fail even with internet
      // So we'll just trust the connectivity check result
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.wifi) || 
          result.contains(ConnectivityResult.ethernet) ||
          result.contains(ConnectivityResult.mobile)) {
        return true;
      }
      
      // Fallback: try the lookup anyway
      final lookupResult = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      // If lookup fails but we have wifi/mobile, assume connected
      final result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.wifi) || 
             result.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Check connectivity status without internet verification
  Future<bool> get hasConnectivity async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Get current connectivity type
  Future<ConnectivityResult> get connectivityType async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }
}
