import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/pages/home_swipe_screen.dart';
import '../../presentation/pages/wish_list_screen.dart';
import '../../presentation/pages/profile_screen.dart';
import '../../presentation/pages/search_screen.dart';
import '../../presentation/pages/filter_screen.dart';
import '../../presentation/pages/cart_screen.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final _pages = const [HomeSwipeScreen(), WishlistScreen(), ProfileScreen()];

  String _getTitle(String? userName) {
    switch (_currentIndex) {
      case 1:
        return 'Wishlist';
      case 2:
        return 'Profile';
      default:
        return userName != null ? 'Hi, $userName!' : 'Discover';
    }
  }

  String _getWelcomeMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 🌤️';
    return 'Good Evening! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.name != null
        ? currentUser!.name.split(' ').first
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.lg,
        title: Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/images/logo1.png',
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.shopping_bag,
                      color: AppColors.primary,
                      size: 20,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentIndex == 0 ? _getWelcomeMessage() : 'Tapto',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _getTitle(userName),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.search_rounded, color: Colors.black87),
              tooltip: 'Search',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.black87),
              tooltip: 'Filter',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FilterScreen()),
                );
              },
            ),
          ],
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black87,
                ),
                tooltip: 'Cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.explore_rounded,
                  label: 'Discover',
                  isSelected: _currentIndex == 0,
                  onTap: () {
                    if (_currentIndex != 0) {
                      setState(() => _currentIndex = 0);
                    }
                  },
                ),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Wishlist',
                  isSelected: _currentIndex == 1,
                  badge: 0,
                  onTap: () {
                    if (_currentIndex != 1) {
                      setState(() => _currentIndex = 1);
                    }
                  },
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex == 2,
                  onTap: () {
                    if (_currentIndex != 2) {
                      setState(() => _currentIndex = 2);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primary : Colors.grey[400],
                    size: 26,
                  ),
                  if (badge != null && badge! > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
