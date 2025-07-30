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
import 'package:flutter/foundation.dart' show kIsWeb ;
import 'screens/profile_screen.dart';
import 'screens/subscription_details_screen.dart';
import 'package:sari_sari/bloc/profile_bloc.dart';
import 'repository/invite_repository.dart';
import 'screens/store_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable all debug prints
  debugPrint = (String? message, {int? wrapWidth}) {};
  
  if (!kIsWeb) {
    await dotenv.load();
  }
  final supabaseUrl = kIsWeb
      ? const String.fromEnvironment('SUPABASE_URL')
      : dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = kIsWeb
      ? const String.fromEnvironment('SUPABASE_ANON_KEY')
      : dotenv.env['SUPABASE_ANON_KEY']!;
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            home: const SplashScreen(),
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
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
