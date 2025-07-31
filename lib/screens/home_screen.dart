import 'package:flutter/material.dart';
import '../components/modern_drawer.dart';
import 'items_screen.dart';
import 'settings_screen.dart';
import '../components/app_layout.dart';
import '../components/dashboard_pro_style.dart';
import '../services/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'store_screen.dart';
import '../bloc/profile_bloc.dart';
import '../repository/invite_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _drawerAnimationController;
  String userType = 'admin'; // Default to admin

  final List<String> _adminTitles = const ['Home', 'Items', 'Store', 'Settings'];
  final List<String> _managerTitles = const ['Home', 'Inventory', 'Settings'];

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    try {
      // This will use cached value, no loading needed
      final type = await UserService.getUserType();
      if (mounted) {
        setState(() {
          userType = type;
        });
      }
    } catch (e) {
      // Error loading user type - handle silently
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  Widget _buildManagerInventoryScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Manager Inventory',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'View and manage store inventory',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> adminScreens = [
      const DashboardProStyle(),      // index 0 - Home
      const ItemsScreen(),            // index 1 - Items  
      BlocProvider(                   // index 2 - Store
        create: (_) => ProfileBloc(inviteRepository: InviteRepository())..add(LoadProfile()),
        child: const StoreScreen(),
      ),
      const SettingsScreen(),         // index 3 - Settings
    ];

    final List<Widget> managerScreens = [
      const DashboardProStyle(),      // index 0 - Home
      _buildManagerInventoryScreen(), // index 1 - Inventory
      const SettingsScreen(),         // index 2 - Settings
    ];

    final screens = userType == 'admin' ? adminScreens : managerScreens;
    final titles = userType == 'admin' ? _adminTitles : _managerTitles;
    
    // Ensure selectedIndex doesn't exceed screen array bounds
    final safeIndex = _selectedIndex >= screens.length ? 0 : _selectedIndex;

    return AppLayout(
      title: titles[safeIndex],
      body: screens[safeIndex],
      drawer: ModernDrawer(
        selectedIndex: safeIndex,
        onItemTapped: _onItemTapped,
        drawerAnimationController: _drawerAnimationController,
      ),
    );
  }
}








