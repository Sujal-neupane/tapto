import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/routes/app_routes.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:tapto/features/auth/presentation/state/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _navigateToNext();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() async {
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final userSessionService = UserSessionService();

      // Check if user is logged in (token/session)
      final isLoggedIn = await userSessionService.isLoggedIn().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      if (isLoggedIn) {
        // Load user from Hive (and API fallback if needed)
        await ref.read(authViewModelProvider.notifier).getCurrentUser();

        // Wait for the AuthState to update (max 2 seconds)
        int waited = 0;
        while (waited < 2000) {
          final authState = ref.read(authViewModelProvider);
          if (authState.status == AuthStatus.authenticated && authState.user != null) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 100));
          waited += 100;
        }

        if (!mounted) return;

        final authState = ref.read(authViewModelProvider);
        final user = authState.user;

        if (authState.status == AuthStatus.authenticated && user != null) {
          if (user.isAdmin) {
            debugPrint('Admin user detected: ${user.email}');
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          } else {
            final isOnboardingComplete = await userSessionService
                .isOnboardingComplete()
                .timeout(const Duration(seconds: 5), onTimeout: () => false);

            debugPrint('Regular user detected: ${user.email}');
            Navigator.pushReplacementNamed(
              context,
              isOnboardingComplete
                  ? AppRoutes.dashboard
                  : AppRoutes.onboarding,
            );
          }
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoSize = screenWidth < 360 ? 100.0 : 120.0;
    final titleFontSize = screenWidth < 360 ? 26.0 : 32.0;
    final subtitleFontSize = screenWidth < 360 ? 14.0 : 16.0;
    final verticalSpacing = screenHeight < 700 ? 30.0 : 40.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo Section
              AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/logo1.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: verticalSpacing),
              // App Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Tapto',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Swift Services, Smart Connections',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Bottom branding
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Text(
                        'Connect. Tap. Serve.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black38,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}