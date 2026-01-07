import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_reminder_flutter/generated/app_localizations.dart';
import 'package:task_reminder_flutter/providers/theme_provider.dart';
import 'package:task_reminder_flutter/providers/locale_provider.dart';
import 'package:task_reminder_flutter/screens/task_list_screen.dart';
import 'package:task_reminder_flutter/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyDf6sPLXW2sWtkkt4XaHPjFPXpkzft03tY",
            authDomain: "taskreminder-480e9.firebaseapp.com",
            projectId: "taskreminder-480e9",
            storageBucket: "taskreminder-480e9.firebasestorage.app",
            messagingSenderId: "148369250702",
            appId: "1:148369250702:web:1b4e43f62a2540f2beacdf",
          )
        : null,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(ThemeOption.system)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Task Reminder',
      theme: themeProvider.themeData,
      darkTheme: ThemeProvider(ThemeOption.dark).themeData,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
        Locale('lo'),
        Locale('ru'),
        Locale('th'),
      ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return TaskListScreen(
                  onThemeChanged: (theme) => themeProvider.setTheme(theme),
                  onLocaleChanged: (locale) =>
                      Provider.of<LocaleProvider>(context, listen: false)
                          .setLocale(locale),
                  currentTheme: themeProvider.themeOption,
                );
              }
              return LoginScreen(
                onThemeChanged: (theme) => themeProvider.setTheme(theme),
                onLocaleChanged: (locale) =>
                    Provider.of<LocaleProvider>(context, listen: false)
                        .setLocale(locale),
                currentTheme: themeProvider.themeOption,
              );
            },
          );
        },
      ),
    );
  }
}