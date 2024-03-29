// theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
