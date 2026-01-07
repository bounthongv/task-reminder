import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Add this
import 'screens/task_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDf6sPLXW2sWtkkt4XaHPjFPXpkzft03tY",
      authDomain: "taskreminder-480e9.firebaseapp.com",
      projectId: "taskreminder-480e9",
      storageBucket: "taskreminder-480e9.firebasestorage.app",
      messagingSenderId: "148369250702",
      appId: "1:148369250702:web:1b4e43f62a2540f2beacdf",
    ),
  );
  runApp(const TaskReminderApp());
}

enum ThemeOption { bright, dark, system }

class TaskReminderApp extends StatefulWidget {
  const TaskReminderApp({super.key});

  @override
  _TaskReminderAppState createState() => _TaskReminderAppState();
}

class _TaskReminderAppState extends State<TaskReminderApp> {
  ThemeOption _themeOption = ThemeOption.system;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLocale();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'system';
    setState(() {
      _themeOption = ThemeOption.values.firstWhere(
        (e) => e.toString().split('.').last == savedTheme,
        orElse: () => ThemeOption.system,
      );
    });
  }

  Future<void> _saveTheme(ThemeOption theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.toString().split('.').last);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale') ?? 'en';
    setState(() {
      _locale = Locale(savedLocale);
    });
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  ThemeData _getTheme(BuildContext context) {
    if (_themeOption == ThemeOption.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? _darkTheme : _brightTheme;
    }
    return _themeOption == ThemeOption.dark ? _darkTheme : _brightTheme;
  }

  final ThemeData _brightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'NotoSansLao', color: Colors.black),
      bodyLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.black),
      titleLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.black),
    ),
    cardColor: Colors.grey[100],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'NotoSansLao', color: Colors.white),
      bodyLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.white),
      titleLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.white),
    ),
    cardColor: Colors.grey[800],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.blueGrey,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminder',
      theme: _getTheme(context),
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('lo'),
        Locale('th'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final user = snapshot.data!;
            if (user.providerData.any((info) => info.providerId == 'google.com') || user.emailVerified) {
              return TaskListScreen(
                onThemeChanged: (theme) {
                  setState(() {
                    _themeOption = theme;
                  });
                  _saveTheme(theme);
                },
                onLocaleChanged: (locale) {
                  _saveLocale(locale);
                },
              );
            }
          }
          return const LoginScreen();
        },
      ),
    );
  }
}