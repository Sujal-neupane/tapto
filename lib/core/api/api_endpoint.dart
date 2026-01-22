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

  // ========== Product Endpoints =========
  static const String products = '/api/products';
  static String productById(String id) => '/api/products/$id';
  static const String productsByCategory = '/api/products/category';

  // ========== Category Endpoints =========
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // ========== Order Endpoints =========
  static const String orders = '/api/orders';
  static String orderById(String id) => '/api/orders/$id';

  // ========== Cart Endpoints =========
  static const String cart = '/api/cart';
  static String cartItemById(String id) => '/api/cart/$id';
}
