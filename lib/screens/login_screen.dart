import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:task_reminder_flutter/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class LoginScreen extends StatelessWidget {
  final ValueChanged<ThemeOption> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeOption currentTheme;

  const LoginScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> loginWithEmail() async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    }

    Future<void> registerWithEmail() async {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    }

    Future<void> resetPassword() async {
      final TextEditingController resetEmailController = TextEditingController();
      if (emailController.text.isNotEmpty) {
        resetEmailController.text = emailController.text;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.resetPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.enterEmailToReset),
              const SizedBox(height: 10),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (resetEmailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.emailRequired)),
                  );
                  return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: resetEmailController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.resetPasswordEmailSent)),
                    );
                  }
                } catch (e) {
                   if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.failedToSendResetEmail)),
                    );
                   }
                }
              },
              child: Text(AppLocalizations.of(context)!.sendResetLink),
            ),
          ],
        ),
      );
    }

    Future<void> signInWithGoogle() async {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // User canceled the sign-in

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          _buildThemeDropdown(context),
          _buildLanguageDropdown(context),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.login,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resetPassword,
                    child: Text(AppLocalizations.of(context)!.forgotPassword),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginWithEmail,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        AppLocalizations.of(context)!.loginButton,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        AppLocalizations.of(context)!.signInWithGoogle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: registerWithEmail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        AppLocalizations.of(context)!.register,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeDropdown(BuildContext context) {
    return DropdownButton<ThemeOption>(
      value: currentTheme,
      onChanged: (ThemeOption? newTheme) {
        if (newTheme != null) {
          onThemeChanged(newTheme);
        }
      },
      items: ThemeOption.values.map((ThemeOption theme) {
        String label;
        switch (theme) {
          case ThemeOption.system:
            label = AppLocalizations.of(context)!.systemTheme;
            break;
          case ThemeOption.bright:
            label = AppLocalizations.of(context)!.brightTheme;
            break;
          case ThemeOption.dark:
            label = AppLocalizations.of(context)!.darkTheme;
            break;
          case ThemeOption.ocean:
            label = AppLocalizations.of(context)!.oceanTheme;
            break;
          case ThemeOption.forest:
            label = AppLocalizations.of(context)!.forestTheme;
            break;
          case ThemeOption.sunset:
            label = AppLocalizations.of(context)!.sunsetTheme;
            break;
        }
        return DropdownMenuItem<ThemeOption>(
          value: theme,
          child: Text(label),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return DropdownButton<Locale>(
      value: Provider.of<LocaleProvider>(context).locale,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          onLocaleChanged(newLocale);
        }
      },
      items: const [
        Locale('en'),
        Locale('de'),
        Locale('lo'),
        Locale('ru'),
        Locale('th'),
      ].map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(locale.languageCode),
        );
      }).toList(),
    );
  }
}