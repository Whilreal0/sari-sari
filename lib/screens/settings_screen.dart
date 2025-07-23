import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_controller.dart';
import '../bloc/auth_bloc.dart' as auth_bloc;
import '../components/subscription_button.dart';
import '../components/invite_manager_button.dart';
import '../bloc/profile_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: BlocProvider(
        create: (_) => ProfileBloc()..add(LoadProfile()),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
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
              const InviteManagerButton(),
              const SubscriptionButton(),
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