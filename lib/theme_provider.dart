import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String? _profilePhotoUrl;
  Color _primaryColor = const Color.fromARGB(255, 27, 86, 90); // Couleur principale par défaut

  bool get isDarkMode => _isDarkMode;
  String? get profilePhotoUrl => _profilePhotoUrl;
  Color get primaryColor => _primaryColor;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setProfilePhotoUrl(String url) {
    _profilePhotoUrl = url;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
            primaryColor: _primaryColor,
            colorScheme: ColorScheme.dark(primary: _primaryColor),
            appBarTheme: AppBarTheme(
              backgroundColor: _primaryColor,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: _primaryColor,
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: _primaryColor,
            colorScheme: ColorScheme.light(primary: _primaryColor),
            appBarTheme: AppBarTheme(
              backgroundColor: _primaryColor,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: _primaryColor,
            ),
          );
  }
}