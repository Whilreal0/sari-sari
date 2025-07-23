import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

// Events
abstract class ThemeEvent {}
class ToggleThemeEvent extends ThemeEvent {}

// State
class ThemeState {
  final ThemeData themeData;
  final bool isDarkMode;
  ThemeState({required this.themeData, required this.isDarkMode});
}

// Controller (Bloc)
class ThemeController extends Bloc<ThemeEvent, ThemeState> {
  ThemeController()
      : super(ThemeState(themeData: lightTheme, isDarkMode: false)) {
    on<ToggleThemeEvent>((event, emit) {
      if (state.isDarkMode) {
        emit(ThemeState(themeData: lightTheme, isDarkMode: false));
      } else {
        emit(ThemeState(themeData: darkTheme, isDarkMode: true));
      }
    });
  }
} 