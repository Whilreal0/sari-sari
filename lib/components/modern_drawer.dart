import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart' as auth_bloc;
import '../services/user_service.dart';

class ModernDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final AnimationController drawerAnimationController;

  const ModernDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.drawerAnimationController,
  });

  @override
  State<ModernDrawer> createState() => _ModernDrawerState();
}

class _ModernDrawerState extends State<ModernDrawer> {
  String? fullName;
  String? userType;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchFullNameAndUserType();
  }

  Future<void> fetchFullNameAndUserType() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        fullName = null;
        userType = 'guest';
        loading = false;
      });
      return;
    }
    
    try {
      // Get user type first
      final type = await UserService.getUserType();
      
      // Get full name based on user type
      String? name;
      if (type == 'admin') {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        name = response?['full_name'] as String?;
      } else if (type == 'manager') {
        final response = await Supabase.instance.client
            .from('manager_profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        name = response?['full_name'] as String?;
      }
      
      setState(() {
        fullName = name;
        userType = type;
        loading = false;
      });
    } catch (e) {
      setState(() {
        fullName = null;
        userType = 'user';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocProvider(
            create: (_) => auth_bloc.AuthBloc(),
            child: BlocListener<auth_bloc.AuthBloc, auth_bloc.AuthState>(
              listener: (context, state) {
                if (state is auth_bloc.AuthSuccess) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else if (state is auth_bloc.AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: Column(
                children: [
                  _buildDrawerHeader(context),
                  Expanded(
                    child: _buildDrawerItems(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: BlocBuilder<auth_bloc.AuthBloc, auth_bloc.AuthState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.logout),
                            label: state is auth_bloc.AuthLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Logout'),
                            onPressed: state is auth_bloc.AuthLoading
                                ? null
                                : () {
                                    context.read<auth_bloc.AuthBloc>().add(auth_bloc.LogoutRequested());
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildAppVersion(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 200, // Increased height to prevent overflow
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.store,
                size: 30,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sari Sari Store',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading
                ? const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName ?? 'Guest',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userType == 'admin' ? 'Admin' : userType == 'manager' ? 'Manager' : 'User',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 4), // Add spacing
            const Text(
              'Your neighborhood store',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    List<Map<String, dynamic>> items = [
      {'icon': Icons.home_outlined, 'title': 'Home', 'index': 0},
      {'icon': Icons.inventory_2_outlined, 'title': 'Items', 'index': 1},
    ];
    
    // Only show Store for admin users
    if (userType == 'admin') {
      items.add({'icon': Icons.store_outlined, 'title': 'Store', 'index': 2});
      items.add({'icon': Icons.settings_outlined, 'title': 'Settings', 'index': 3});
    } else {
      items.add({'icon': Icons.settings_outlined, 'title': 'Settings', 'index': 2});
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = widget.selectedIndex == item['index'];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: ListTile(
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                size: 22,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () => widget.onItemTapped(item['index'] as int),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppVersion(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            height: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}











