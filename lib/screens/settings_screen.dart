import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_controller.dart';
import '../services/user_service.dart';

import '../components/subscription_button.dart';
import '../components/manager_button.dart';
import '../bloc/profile_bloc.dart';
import '../repository/invite_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userType = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    try {
      final type = await UserService.getUserType();
      if (mounted) {
        setState(() {
          userType = type;
        });
      }
    } catch (e) {
      // Error loading user type - handle silently or use proper logging
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: BlocProvider(
        create: (_) => ProfileBloc(inviteRepository: InviteRepository())..add(LoadProfile()),
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Profile'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    elevation: 0,
                  ),
                ),
              ),
              // Only show Managers button for admin users
              if (userType == 'admin') ManagerButton(),
              // Show subscription button for all users
              SubscriptionButton(),
              // Only show Codes button for admin users
              if (userType == 'admin')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Codes'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/codes');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 0,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                label: Text(isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
                onPressed: () {
                  context.read<ThemeController>().add(ToggleThemeEvent());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}






