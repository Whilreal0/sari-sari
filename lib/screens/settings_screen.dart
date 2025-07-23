import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_controller.dart';
import '../bloc/auth_bloc.dart' as auth_bloc;

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
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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