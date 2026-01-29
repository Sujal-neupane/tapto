import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String compIpAddress= "192.168.x.x"; // Replace with your computer's local IP address

  static String get baseUrl{
    if(isPhysicalDevice){
      return 'http://$compIpAddress:4000';
    }
    if(kIsWeb){
      return 'http://10.2.2.2:4000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000';
    } else if (Platform.isIOS) {
      return 'http://localhost:4000';
    } else {
      return 'http://localhost:4000';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // ========== Auth Endpoints ==========
  static const String user = '/api/auth';
  static const String userLogin = '/api/auth/login';
  static const String userRegister = '/api/auth/register';
  static String userById(String id) => '/api/auth/$id';
  static const String uploadImage = '/api/auth/upload-profile-picture';

  // ========== Product Endpoints =========
  static const String products = '/admin/products';
  static String productById(String id) => '/admin/products/$id';
  static const String productsByCategory = '/admin/products/category';

  // ========== Category Endpoints =========
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // ========== Order Endpoints =========
  static const String orders = '/api/orders';
  static const String userOrders = '/api/orders/my-orders';
  static String orderById(String id) => '/api/orders/$id';
  static const String orderStatusUpdate = '/api/orders/status';
  static const String liveTrackingUpdate = '/api/orders/:id/track';
  static const String cancelOrder = '/api/orders/cancel';
  static const String updateorderStatus  = '/api/orders/:id/status';
  static const String updateLiveLocation  = '/api/orders/:id/location';
  static String orderTracking(String id) => '/api/orders/$id/track';


  // ========== Cart Endpoints =========
  static const String cart = '/api/cart';
  static String cartItemById(String id) => '/api/cart/$id';
}
