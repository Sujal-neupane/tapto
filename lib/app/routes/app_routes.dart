import 'package:flutter/material.dart';
import 'package:tapto/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:tapto/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/cart_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/checkout_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/filter_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/setting_screen.dart';
import 'package:tapto/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/search_screen.dart';
import 'package:tapto/features/auth/presentation/pages/signup_screen.dart';
import 'package:tapto/features/orders/presentation/pages/my_orders_screen.dart';
import 'package:tapto/features/splash/presentation/pages/splash_screen.dart';
import 'package:tapto/features/auth/presentation/pages/login_screen.dart';
import 'package:tapto/features/dashboard/presentation/pages/wish_list_screen.dart';

/// Centralized route definitions for the application
class AppRoutes {
  /// Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String onboarding = '/onboarding';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String filter = '/filter';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String wishlist = '/wish-list';
  static const String setting = '/setting';
  static const String myOrders = '/my-orders';
  static const String adminDashboard = '/admin-dashboard';
  static const String checkOut = '/check-out';
  static const String orderDetails = '/order-details';
  static const String orderTracking = '/order-tracking';

  /// Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const RegisterScreen(),
    dashboard: (context) => const DashboardScreen(),
    onboarding: (context) => const OnboardingScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    filter: (context) => const FilterScreen(),
    search: (context) => const SearchScreen(),
    cart: (context) => const CartScreen(),
    wishlist: (context) => const WishlistScreen(),
    setting: (context) => const SettingScreen(),
    myOrders: (context) => const MyOrdersScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    checkOut: (context) => const CheckoutScreen(),
  };
}
