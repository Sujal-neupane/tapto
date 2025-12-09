import 'package:flutter/material.dart';
import 'package:tapto/navigation/bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/images/logo1.png'),
          height: 40,
        ),
        backgroundColor: Colors.white,
      ),
      body: const Center(child: Text('Dashboard Content Here')),

      bottomNavigationBar: BottomNav(type: BottomNavigationBarType.fixed),
    );
  }
}
