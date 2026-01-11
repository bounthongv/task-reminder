import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserTier { free, supporter, pro }

class UserProvider extends ChangeNotifier {
  UserTier _tier = UserTier.free;
  static const String _tierKey = 'user_tier';

  UserProvider() {
    _loadTier();
  }

  UserTier get tier => _tier;

  bool get isPremium => _tier != UserTier.free;
  bool get isPro => _tier == UserTier.pro;

  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  Future<void> _loadTier() async {
    final prefs = await SharedPreferences.getInstance();
    final tierIndex = prefs.getInt(_tierKey) ?? 0;
    _tier = UserTier.values[tierIndex];
    notifyListeners();
  }

  Future<void> updateTier(UserTier newTier) async {
    _tier = newTier;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tierKey, newTier.index);
    notifyListeners();
  }
}