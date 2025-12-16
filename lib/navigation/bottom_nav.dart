// import 'package:flutter/material.dart';
// import 'package:tapto/screens/home_screen.dart';
// import 'package:tapto/screens/profile_screen.dart';
// import 'package:tapto/screens/wish_list_screen.dart';

// class BottomNav extends StatefulWidget {
//   const BottomNav({super.key, required BottomNavigationBarType type});

//   @override
//   State<BottomNav> createState() => _BottomNavState();
// }

// class _BottomNavState extends State<BottomNav> {
//   int _selectedIndex = 0;

//   static const List<Widget> _pages = <Widget>[
//     HomeScreen(),
//     WishlistScreen(),
//     ProfileScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: BottomNavigationBar.navItems(),
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
