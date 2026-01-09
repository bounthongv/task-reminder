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

import 'package:task_reminder_flutter/services/notification_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:task_reminder_flutter/services/system_tray_service.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: true, // Hide from taskbar
      titleBarStyle: TitleBarStyle.normal,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setIcon('assets/app_icon.ico'); // Force proper icon
      // Do not show window on start, just init tray
    });
  }

  // Initialize Notification Service
  await NotificationService().init();

  // Initialize Firebase with platform-specific options
  const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyDf6sPLXW2sWtkkt4XaHPjFPXpkzft03tY",
    authDomain: "taskreminder-480e9.firebaseapp.com",
    projectId: "taskreminder-480e9",
    storageBucket: "taskreminder-480e9.firebasestorage.app",
    messagingSenderId: "148369250702",
    appId: "1:148369250702:web:1b4e43f62a2540f2beacdf",
  );

  await Firebase.initializeApp(
    options: (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) 
        ? firebaseOptions 
        : null,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(ThemeOption.ocean)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize System Tray (needs context, but usually better initialized after MaterialApp is mounted, 
    // or passed a context key. For simplicity, we can do it in the first screen or using a builder).
    // Actually, initializing it here might be too early for context-based dialogs if we don't have a navigator context.
    // Let's defer initialization to the HomePage (TaskListScreen/LoginScreen) or use a Builder below.
  }

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
      home: Builder(
        builder: (context) {
          // Initialize System Tray here where we have a valid Navigator context
          if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
             // We ensure this only runs once or handle re-initialization gracefully
             // Ideally this should be a stateful widget inside Home or a dedicated Init widget.
             // For now, let's call it from the screens or here. 
             // Calling it here might happen on rebuilds, but SystemTrayService.init is idempotent-ish or we can check a flag.
             // Better approach: Wrap home in a wrapper widget that inits tray.
             SystemTrayService().init(context);
          }
          
          return Consumer<ThemeProvider>(
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
          );
        }
      ),
    );
  }
}