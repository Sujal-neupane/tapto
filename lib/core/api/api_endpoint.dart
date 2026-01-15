class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // Uncomment the one that matches your setup:

  // For Android Emulator use:
  static const String baseUrl = 'http://10.0.2.2:3000';

  // For iOS Simulator use:
  // static const String baseUrl = 'http://localhost:3000';

  // For Physical Device - replace 192.168.x.x with your actual machine IP:
  // static const String baseUrl = 'http://192.168.x.x:3000';

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // ========== Auth Endpoints ==========
  static const String user = '/auth';
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static String userById(String id) => '/auth/$id';

  // ========== Product Endpoints =========
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String productsByCategory = '/products/category';

  // ========== Category Endpoints =========
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ========== Order Endpoints =========
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // ========== Cart Endpoints =========
  static const String cart = '/cart';
  static String cartItemById(String id) => '/cart/$id';
}
