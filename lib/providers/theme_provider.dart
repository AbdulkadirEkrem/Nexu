import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool isDarkMode(BuildContext? context) {
    if (_themeMode == ThemeMode.dark) {
      return true;
    }
    if (_themeMode == ThemeMode.light) {
      return false;
    }
    // For ThemeMode.system, check the system brightness
    if (context != null) {
      return Theme.of(context).brightness == Brightness.dark;
    }
    return false; // Default fallback
  }

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}

