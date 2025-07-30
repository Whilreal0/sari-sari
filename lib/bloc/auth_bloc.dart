import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../services/user_service.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  RegisterRequested(this.email, this.password, this.fullName);
}

class LogoutRequested extends AuthEvent {}

// STATES
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        if (response.user != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure('Login failed'));
        }
      } on SocketException {
        emit(AuthFailure('No internet connection. Please check your network.'));
      } catch (e) {
        String errorMsg = 'Login failed';
        if (e is AuthApiException) {
          final lowerMsg = e.message.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
          if (lowerMsg.contains('invalidlogincredentials')) {
            errorMsg = 'Incorrect email or password.'; // Your custom message
          } else if (lowerMsg.contains('emailnotconfirmed') || lowerMsg.contains('emailnotconfirmed')) {
            errorMsg = 'Please verify your email to log in.';
          } else {
            errorMsg = e.message;
          }
        } else if (e is Exception) {
          errorMsg = e.toString();
        }
        emit(AuthFailure(errorMsg));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: event.email,
          password: event.password,
        );
        if (response.user != null) {
          // Insert full name into profiles table
          await Supabase.instance.client.from('profiles').upsert({
            'id': response.user!.id,
            'full_name': event.fullName,
            'email': event.email,
          });
          emit(AuthSuccess());
        } else {
          emit(AuthFailure('Registration failed'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Supabase.instance.client.auth.signOut();
        // Clear user type cache on logout
        await UserService.clearUserTypeCache();
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure('Logout failed: ${e.toString()}'));
      }
    });
  }
}
