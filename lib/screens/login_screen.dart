import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sari_sari/bloc/auth_bloc.dart' as auth_bloc;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isCapsLockOn = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _getCustomErrorMessage(String originalError) {
    final error = originalError.toLowerCase();
    
    // Add debug print to see what error we're getting
    print('Original error: $originalError');
    
    if (error.contains('network') || error.contains('connection') || error.contains('timeout')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.contains('invalid login credentials') || 
               error.contains('invalid_credentials') ||
               error.contains('invalid credentials') ||
               error.contains('wrong password') ||
               error.contains('incorrect password') ||
               error.contains('authentication failed') ||
               (error.contains('auth') && error.contains('fail'))) {
      return 'Incorrect email or password. Please try again.';
    } else if (error.contains('email not confirmed') || 
               error.contains('email_not_confirmed') ||
               error.contains('not confirmed')) {
      return 'Please verify your email address before logging in.';
    } else if (error.contains('too many requests') || 
               error.contains('rate_limit') ||
               error.contains('rate limit')) {
      return 'Too many login attempts. Please wait a moment and try again.';
    } else if (error.contains('user not found') || 
               error.contains('user_not_found') ||
               error.contains('no user found')) {
      return 'No account found with this email address.';
    } else if (error.contains('invalid email') || 
               (error.contains('email') && error.contains('invalid'))) {
      return 'Please enter a valid email address.';
    } else if (error.contains('account disabled') || 
               error.contains('disabled') ||
               error.contains('suspended')) {
      return 'Your account has been disabled. Please contact support.';
    } else if (error.contains('password')) {
      return 'Incorrect password. Please try again.';
    } else {
      // Show the original error for debugging, then return custom message
      print('Unhandled error type: $originalError');
      return 'Login failed. Please check your credentials and try again.';
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _onPasswordChanged(String value) {
    // Simple caps lock detection based on character patterns
    bool hasCaps = value.isNotEmpty && value == value.toUpperCase() && value != value.toLowerCase();
    if (hasCaps != _isCapsLockOn) {
      setState(() {
        _isCapsLockOn = hasCaps;
      });
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validate email format
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check password length
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<auth_bloc.AuthBloc>().add(auth_bloc.LoginRequested(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<auth_bloc.AuthBloc, auth_bloc.AuthState>(
      listener: (context, state) {
        if (state is auth_bloc.AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          // Navigate to home screen after successful login
          Future.delayed(const Duration(seconds: 1), () {
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
          });
        } else if (state is auth_bloc.AuthFailure) {
          String customErrorMsg = _getCustomErrorMessage(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(customErrorMsg), backgroundColor: Colors.red),
          );
        }
      },
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      onChanged: _onPasswordChanged,
                    ),
                    if (_isCapsLockOn)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: const [
                            Icon(Icons.warning, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Caps Lock is on',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: BlocBuilder<auth_bloc.AuthBloc, auth_bloc.AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is auth_bloc.AuthLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: state is auth_bloc.AuthLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
