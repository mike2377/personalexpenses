import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String? _profilePhotoUrl;

  bool get isDarkMode => _isDarkMode;
  String? get profilePhotoUrl => _profilePhotoUrl;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setProfilePhotoUrl(String url) {
    _profilePhotoUrl = url;
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}