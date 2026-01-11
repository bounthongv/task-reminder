import 'package:flutter/material.dart';

enum ThemeOption {
  system,
  bright,
  dark,
  ocean,  // New: Blue tones
  forest, // New: Green tones
  sunset, // New: Orange and purple tones
}

class ThemeProvider with ChangeNotifier {
  ThemeOption _themeOption;

  ThemeProvider(this._themeOption);

  ThemeOption get themeOption => _themeOption;

  void setTheme(ThemeOption option) {
    _themeOption = option;
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_themeOption) {
      case ThemeOption.system:
        return ThemeData(
          brightness: Brightness.light, // Fallback, system will override
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme: const AppBarTheme(
            color: Colors.blue,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        );
      case ThemeOption.bright:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            color: Colors.blue,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        );
      case ThemeOption.dark:
        return ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: const AppBarTheme(
            color: Colors.blueGrey,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
        );
      case ThemeOption.ocean:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.cyan,
          scaffoldBackgroundColor: Colors.cyan[50],
          appBarTheme: const AppBarTheme(
            color: Colors.cyan,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black54),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        );
      case ThemeOption.forest:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.green[50],
          appBarTheme: const AppBarTheme(
            color: Colors.green,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black54),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        );
      case ThemeOption.sunset:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.orange[50],
          appBarTheme: const AppBarTheme(
            color: Colors.deepOrange,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black54),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        );
    }
  }

  ThemeMode get themeMode {
    switch (_themeOption) {
      case ThemeOption.system:
        return ThemeMode.system;
      case ThemeOption.bright:
      case ThemeOption.ocean:
      case ThemeOption.forest:
      case ThemeOption.sunset:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
    }
  }

  static bool isThemePremium(ThemeOption option) {
    return option == ThemeOption.ocean ||
        option == ThemeOption.forest ||
        option == ThemeOption.sunset;
  }
}