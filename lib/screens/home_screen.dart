import 'package:flutter/material.dart';
import '../components/modern_drawer.dart';
import 'items_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';
import '../components/app_layout.dart';
import '../components/dashboard_pro_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _salesTabIndex = 2; // 0: Daily, 1: Weekly, 2: Monthly
  late AnimationController _drawerAnimationController;

  final List<String> _titles = const [
    'Home',
    'Items',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const DashboardProStyle(),
      const ItemsScreen(),
      const SettingsScreen(),
    ];
    return AppLayout(
      title: _titles[_selectedIndex],
      body: _screens[_selectedIndex],
      drawer: ModernDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        drawerAnimationController: _drawerAnimationController,
      ),
    );
  }

 
}