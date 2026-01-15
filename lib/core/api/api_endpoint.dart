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
