// // lib/screens/dashboard/dashboard_screen.dart
// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;

//   final List<Map<String, dynamic>> _statsCards = [
//     {
//       'title': 'Total Users',
//       'value': '2,543',
//       'change': '+12.5%',
//       'isPositive': true,
//       'icon': Icons.people_outline,
//       'color': AppColors.primary,
//     },
//     {
//       'title': 'Revenue',
//       'value': '\$45,678',
//       'change': '+8.2%',
//       'isPositive': true,
//       'icon': Icons.attach_money,
//       'color': AppColors.success,
//     },
//     {
//       'title': 'Orders',
//       'value': '1,234',
//       'change': '-3.1%',
//       'isPositive': false,
//       'icon': Icons.shopping_cart_outlined,
//       'color': AppColors.warning,
//     },
//     {
//       'title': 'Growth',
//       'value': '32.5%',
//       'change': '+5.4%',
//       'isPositive': true,
//       'icon': Icons.trending_up,
//       'color': AppColors.info,
//     },
//   ];

//   final List<Map<String, String>> _recentActivities = [
//     {
//       'title': 'New user registered',
//       'subtitle': 'John Doe joined the platform',
//       'time': '5 min ago',
//     },
//     {
//       'title': 'Payment received',
//       'subtitle': 'Order #1234 - \$299.00',
//       'time': '15 min ago',
//     },
//     {
//       'title': 'New order placed',
//       'subtitle': 'Order #1233 from Jane Smith',
//       'time': '1 hour ago',
//     },
//     {
//       'title': 'Product updated',
//       'subtitle': 'iPhone 15 Pro stock updated',
//       'time': '2 hours ago',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {
//               // Handle notifications
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.shopping_cart_outlined),
//             onPressed: () {
//               // Handle cart
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings_outlined),
//             onPressed: () {
//               // Handle settings
//             },
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           // Handle refresh
//           await Future.delayed(const Duration(seconds: 1));
//         },
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(AppSpacing.md),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Welcome Section
//               _buildWelcomeSection(),

//               const SizedBox(height: AppSpacing.lg),

//               // Stats Cards Grid
//               _buildStatsGrid(),

//               const SizedBox(height: AppSpacing.lg),

//               // Quick Actions
//               _buildQuickActions(),

//               const SizedBox(height: AppSpacing.lg),

//               // Chart Section
//               _buildChartSection(),

//               const SizedBox(height: AppSpacing.lg),

//               // Recent Activity
//               _buildRecentActivity(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   Widget _buildWelcomeSection() {
//     return Card(
//       elevation: 0,
//       color: AppColors.primary,
//       child: Padding(
//         padding: const EdgeInsets.all(AppSpacing.lg),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: AppColors.white,
//               child: const Icon(
//                 Icons.person,
//                 size: 32,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(width: AppSpacing.md),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome back,',
//                     style: AppTypography.bodySmall.copyWith(
//                       color: AppColors.white.withOpacity(0.9),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'John Doe',
//                     style: AppTypography.h4.copyWith(color: AppColors.white),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.chevron_right, color: AppColors.white),
//               onPressed: () {
//                 // Navigate to profile
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGrid() {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: AppSpacing.md,
//         mainAxisSpacing: AppSpacing.md,
//         childAspectRatio: 1.4,
//       ),
//       itemCount: _statsCards.length,
//       itemBuilder: (context, index) {
//         final card = _statsCards[index];
//         return Card(
//           child: Padding(
//             padding: const EdgeInsets.all(AppSpacing.md),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(AppSpacing.sm),
//                       decoration: BoxDecoration(
//                         color: (card['color'] as Color).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(AppBorderRadius.md),
//                       ),
//                       child: Icon(
//                         card['icon'] as IconData,
//                         color: card['color'] as Color,
//                         size: 24,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: AppSpacing.sm,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: (card['isPositive'] as bool)
//                             ? AppColors.successBg
//                             : AppColors.errorBg,
//                         borderRadius: BorderRadius.circular(
//                           AppBorderRadius.full,
//                         ),
//                       ),
//                       child: Text(
//                         card['change'] as String,
//                         style: AppTypography.caption.copyWith(
//                           color: (card['isPositive'] as bool)
//                               ? AppColors.success
//                               : AppColors.error,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(card['value'] as String, style: AppTypography.h3),
//                     const SizedBox(height: 4),
//                     Text(
//                       card['title'] as String,
//                       style: AppTypography.bodySmall,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQuickActions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Quick Actions', style: AppTypography.h4),
//         const SizedBox(height: AppSpacing.md),
//         Row(
//           children: [
//             Expanded(
//               child: _buildActionButton(
//                 icon: Icons.add_circle_outline,
//                 label: 'Add New',
//                 onTap: () {},
//               ),
//             ),
//             const SizedBox(width: AppSpacing.sm),
//             Expanded(
//               child: _buildActionButton(
//                 icon: Icons.search,
//                 label: 'Search',
//                 onTap: () {},
//               ),
//             ),
//             const SizedBox(width: AppSpacing.sm),
//             Expanded(
//               child: _buildActionButton(
//                 icon: Icons.file_download_outlined,
//                 label: 'Export',
//                 onTap: () {},
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(AppBorderRadius.lg),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
//           child: Column(
//             children: [
//               Icon(icon, color: AppColors.primary, size: 28),
//               const SizedBox(height: AppSpacing.xs),
//               Text(label, style: AppTypography.bodySmall),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChartSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(AppSpacing.md),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Performance Overview', style: AppTypography.h5),
//                 TextButton(onPressed: () {}, child: const Text('View All')),
//               ],
//             ),
//             const SizedBox(height: AppSpacing.md),
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: AppColors.grey100,
//                 borderRadius: BorderRadius.circular(AppBorderRadius.md),
//               ),
//               child: const Center(child: Text('Chart Placeholder')),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentActivity() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Recent Activity', style: AppTypography.h4),
//             TextButton(onPressed: () {}, child: const Text('View All')),
//           ],
//         ),
//         const SizedBox(height: AppSpacing.sm),
//         Card(
//           child: ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _recentActivities.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final activity = _recentActivities[index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: AppColors.primary.withOpacity(0.1),
//                   child: const Icon(
//                     Icons.history,
//                     color: AppColors.primary,
//                     size: 20,
//                   ),
//                 ),
//                 title: Text(
//                   activity['title']!,
//                   style: AppTypography.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 subtitle: Text(activity['subtitle']!),
//                 trailing: Text(activity['time']!, style: AppTypography.caption),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDrawer() {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: const BoxDecoration(color: AppColors.primary),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const CircleAvatar(
//                   radius: 30,
//                   backgroundColor: AppColors.white,
//                   child: Icon(Icons.person, size: 32, color: AppColors.primary),
//                 ),
//                 const SizedBox(height: AppSpacing.sm),
//                 Text(
//                   'John Doe',
//                   style: AppTypography.h5.copyWith(color: AppColors.white),
//                 ),
//                 Text(
//                   'john.doe@example.com',
//                   style: AppTypography.bodySmall.copyWith(
//                     color: AppColors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.dashboard_outlined),
//             title: const Text('Dashboard'),
//             onTap: () => Navigator.pop(context),
//           ),
//           ListTile(
//             leading: const Icon(Icons.person_outline),
//             title: const Text('Profile'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text('Settings'),
//             onTap: () {},
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: AppColors.error),
//             title: const Text(
//               'Logout',
//               style: TextStyle(color: AppColors.error),
//             ),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
//     return NavigationBar(
//       selectedIndex: _selectedIndex,
//       onDestinationSelected: (index) {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       destinations: const [
//         NavigationDestination(
//           icon: Icon(Icons.dashboard_outlined),
//           selectedIcon: Icon(Icons.dashboard),
//           label: 'Dashboard',
//         ),
//         NavigationDestination(
//           icon: Icon(Icons.favorite_border),
//           selectedIcon: Icon(Icons.favorite),
//           label: 'Wish List',
//         ),
//         NavigationDestination(
//           icon: Icon(Icons.person_outline),
//           selectedIcon: Icon(Icons.person),
//           label: 'Profile',
//         ),
//       ],
//     );
//   }
// }
