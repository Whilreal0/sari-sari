import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/theme.dart';
import 'theme/theme_controller.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sari_sari/bloc/auth_bloc.dart' as auth_bloc;
import 'screens/profile_screen.dart';
import 'screens/subscription_details_screen.dart';
import 'package:sari_sari/bloc/profile_bloc.dart';
import 'repository/invite_repository.dart';
import 'screens/store_screen.dart';
import 'screens/codes_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file for mobile builds
  await dotenv.load();
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Missing Supabase configuration');
  }
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeController(),
      child: BlocBuilder<ThemeController, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Sari Sari Store',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) return;
                
                final shouldPop = await _onWillPop(context);
                if (shouldPop && context.mounted) {
                  SystemNavigator.pop();
                }
              },
              child: const SplashScreen(),
            ),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/login': (context) => BlocProvider(
                create: (_) => auth_bloc.AuthBloc(),
                child: const LoginScreen(),
              ),
              '/register': (context) => BlocProvider(
                create: (_) => auth_bloc.AuthBloc(),
                child: BlocListener<auth_bloc.AuthBloc, auth_bloc.AuthState>(
                  listener: (context, state) {
                    if (state is auth_bloc.AuthSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registration successful! Please confirm the email sent to you before logging in.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Optionally, after a delay, pop back to login screen:
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.of(context).pop();
                      });
                    } else if (state is auth_bloc.AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  child: const RegisterScreen(),
                ),
              ),
              '/profile': (context) => const ProfileScreen(),
              '/subscription-details': (context) => BlocProvider(
                create: (_) => ProfileBloc(inviteRepository: InviteRepository())..add(LoadProfile()),
                child: const SubscriptionDetailsScreen(),
              ),
              '/store': (context) => BlocProvider(
                create: (_) => ProfileBloc(inviteRepository: InviteRepository())..add(LoadProfile()),
                child: const StoreScreen(),
              ),
              '/codes': (context) => const CodesScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
