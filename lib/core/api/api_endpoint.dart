import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String compIpAddress = "localhost"; 

  static String get baseUrl {
    // Prioritize platform-specific configurations
    if (kIsWeb) {
      return 'http://$compIpAddress:4000';
    } else if (Platform.isAndroid) {
      // Use 10.0.2.2 for Android emulator to access host machine
      return 'http://172.25.0.41:4000';
    } else if (Platform.isIOS) {
      return 'http://localhost:4000';
    } else {
      // macOS, Linux, Windows desktop
      return 'http://localhost:4000';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Auth Endpoints
  static const String user = '/api/auth';
  static const String userLogin = '/api/auth/login';
  static const String userRegister = '/api/auth/register';
  static const String currentUser = '/api/auth/me';
  static String userById(String id) => '/api/auth/$id';
  static const String uploadImage = '/api/auth/upload-profile-picture';
  static const String requestPasswordReset = '/api/auth/request-password-reset';
  static const String resetPassword = '/api/auth/reset-password';

  // Product Endpoints (Public - for users)
  static const String products = '/api/products';
  static String productById(String id) => '/api/products/$id';
  static const String productCategories = '/api/products/categories';
  static String productsByCategory(String category) =>
      '/api/products/category/$category';
  static String productsByFashionType(String fashionType) =>
      '/api/products?category=$fashionType';

  // Admin Product Endpoints
  static const String adminProducts = '/api/admin/products';
  static String adminProductById(String id) => '/api/admin/products/$id';

  // Category Endpoints
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // Order Endpoints
  static const String orders = '/api/orders';
  static const String userOrders = '/api/orders/my-orders';
  static String orderById(String id) => '/api/orders/$id';
  // Admin/authorized updates (id required)
  static String orderStatusById(String id) => '/api/orders/$id/status';
  static String orderTracking(String id) => '/api/orders/$id/track';
  static String orderLocationById(String id) => '/api/orders/$id/location';
  static String orderCancelById(String id) => '/api/orders/$id/cancel';

  // Address Endpoints
  static const String addresses = '/api/addresses';
  static String addressById(String id) => '/api/addresses/$id';
  static String addressSetDefault(String id) => '/api/addresses/$id/default';

  // Cart Endpoints
  static const String cart = '/api/cart';
  static const String cartSync = '/api/cart/sync';
  static String cartItemById(String id) => '/api/cart/$id';
}
