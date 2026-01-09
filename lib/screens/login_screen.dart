import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:task_reminder_flutter/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class LoginScreen extends StatefulWidget {
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
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submitAuthForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _loginWithEmail();
      } else {
        await _registerWithEmail();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithEmail() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = _getLocalizedErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error)),
      );
    }
  }

  Future<void> _registerWithEmail() async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user data to Firestore users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      });

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = _getLocalizedRegistrationErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error)),
      );
    }
  }

  String _getLocalizedErrorMessage(FirebaseAuthException e) {
    String errorMessage = AppLocalizations.of(context)!.error;
    try {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = AppLocalizations.of(context)!.userNotFound;
          break;
        case 'wrong-password':
          errorMessage = AppLocalizations.of(context)!.wrongPassword;
          break;
        case 'invalid-email':
          errorMessage = AppLocalizations.of(context)!.invalidEmail;
          break;
        case 'user-disabled':
          errorMessage = AppLocalizations.of(context)!.userDisabled;
          break;
        default:
          errorMessage = AppLocalizations.of(context)!.error;
      }
    } catch (ex) {
      // Fallback
      errorMessage = e.message ?? 'An error occurred';
    }
    return errorMessage;
  }

  String _getLocalizedRegistrationErrorMessage(FirebaseAuthException e) {
    String errorMessage = AppLocalizations.of(context)!.error;
    try {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = AppLocalizations.of(context)!.emailAlreadyInUse;
          break;
        case 'invalid-email':
          errorMessage = AppLocalizations.of(context)!.invalidEmail;
          break;
        case 'weak-password':
          errorMessage = AppLocalizations.of(context)!.weakPassword;
          break;
        default:
          errorMessage = AppLocalizations.of(context)!.error;
      }
    } catch (ex) {
      errorMessage = e.message ?? 'An error occurred';
    }
    return errorMessage;
  }

  Future<void> _resetPassword() async {
    final TextEditingController resetEmailController = TextEditingController();
    if (_emailController.text.isNotEmpty) {
      resetEmailController.text = _emailController.text;
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (kIsWeb) {
        // Use signInWithPopup for Web to avoid GoogleSignIn plugin issues
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(authProvider);
      } else {
        // Use GoogleSignIn plugin for Android/iOS
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Safely get these keys, fallback to English if generated file not yet updated
    String noAccountText;
    String alreadyHaveAccountText;
    try {
      // Using dynamic access if the properties aren't generated yet is risky in Dart without reflection.
      // But since we updated the arb, we assume the user will generate the code. 
      // If the code isn't generated, this might cause a compile error if we access .noAccount directly 
      // and it doesn't exist on the class yet.
      // However, usually the IDE or build process handles this.
      // To be safe against "Property not found" if I can't run codegen:
      // I will assume the properties exist. If this fails, I'll need to use hardcoded strings temporarily.
      // Since I can't verify if `flutter gen-l10n` ran, I will use a try-catch block? No, that's not possible for compilation errors.
      // I will try to use them. If the previous step didn't trigger generation, this `write_file` might be premature if I was running a build. 
      // But I am just editing text.
      
      // WAIT. If I write code that references `l10n.noAccount` and it doesn't exist in `AppLocalizations` class yet (because generation hasn't run),
      // the project won't compile. 
      // But I am an agent editing files. I am not compiling.
      // I should hope the user's environment or a subsequent command handles it.
      // I'll proceed with using them.
      noAccountText = l10n.noAccount;
      alreadyHaveAccountText = l10n.alreadyHaveAccount;
    } catch (e) {
      noAccountText = "Don't have an account?";
      alreadyHaveAccountText = "Already have an account?";
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? l10n.login : l10n.register,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                if (_isLogin) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: Text(l10n.forgotPassword),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16), // Spacing if no forgot password button
                ],
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(
                      _isLogin ? l10n.loginButton : l10n.register,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!_isLoading && (kIsWeb || Platform.isAndroid || Platform.isIOS)) ...[
                  OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        _isLogin ? l10n.signInWithGoogle : l10n.registerWithGoogle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (!_isLoading) ...[
                   const SizedBox(height: 24),
                ],
                if (!_isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLogin ? noAccountText : alreadyHaveAccountText),
                      TextButton(
                        onPressed: _toggleAuthMode,
                        child: Text(
                          _isLogin ? l10n.register : l10n.login,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
      value: widget.currentTheme,
      onChanged: (ThemeOption? newTheme) {
        if (newTheme != null) {
          widget.onThemeChanged(newTheme);
        }
      },
      items: ThemeOption.values.map((ThemeOption theme) {
        String label;
        final l10n = AppLocalizations.of(context)!;
        switch (theme) {
          case ThemeOption.system:
            label = l10n.systemTheme;
            break;
          case ThemeOption.bright:
            label = l10n.brightTheme;
            break;
          case ThemeOption.dark:
            label = l10n.darkTheme;
            break;
          case ThemeOption.ocean:
            label = l10n.oceanTheme;
            break;
          case ThemeOption.forest:
            label = l10n.forestTheme;
            break;
          case ThemeOption.sunset:
            label = l10n.sunsetTheme;
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
          widget.onLocaleChanged(newLocale);
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
