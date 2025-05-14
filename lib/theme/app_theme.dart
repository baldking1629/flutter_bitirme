import 'package:flutter/material.dart';

class AppTheme {
  // Renk paleti
  static const Color _primaryLight = Color(0xFF6200EE);
  static const Color _primaryDark = Color(0xFFBB86FC);
  static const Color _secondaryLight = Color(0xFF03DAC6);
  static const Color _secondaryDark = Color(0xFF03DAC6);
  static const Color _errorLight = Color(0xFFB00020);
  static const Color _errorDark = Color(0xFFCF6679);

  // Ortak değerler
  static const double _borderRadius = 16.0;
  static const double _cardElevation = 2.0;
  static const double _inputBorderRadius = 12.0;
  static const double _buttonHeight = 50.0;
  static const EdgeInsets _cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _screenPadding = EdgeInsets.all(16.0);

  // Ortak stil tanımlamaları
  static final _cardTheme = CardTheme(
    elevation: _cardElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
    margin: EdgeInsets.symmetric(vertical: 8.0),
  );

  static final _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_inputBorderRadius),
    ),
    filled: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
  );

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, _buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.0),
    ),
  );

  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(double.infinity, _buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.0),
    ),
  );

  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: Size(double.infinity, _buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.0),
    ),
  );

  // Açık tema
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF43A047), // Daha canlı yeşil
      secondary: Color(0xFF7CB342), // Daha canlı açık yeşil
      surface: Color(0xFFF5F5F5), // Açık gri
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    ),
    cardTheme: _cardTheme,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: _primaryLight,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.black54,
      ),
    ),
  );

  // Koyu tema
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF66BB6A), // Daha canlı koyu yeşil
      secondary: Color(0xFF9CCC65), // Daha canlı koyu açık yeşil
      surface: Color(0xFF424242), // Koyu gri
      background: Color(0xFF303030), // Antrasit
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
    cardTheme: _cardTheme,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.grey[900],
      foregroundColor: _primaryDark,
    ),
    scaffoldBackgroundColor: Colors.grey[850],
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white70,
      ),
    ),
  );

  // Ortak padding değerleri
  static const EdgeInsets screenPadding = _screenPadding;
  static const EdgeInsets cardPadding = _cardPadding;
}
