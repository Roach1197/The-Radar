import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaywallManager with ChangeNotifier {
  static const String _premiumKey = 'is_premium_user';
  static const String _usageCountKey = 'trial_usage_count';
  static const int _trialLimit = 5;

  bool _isPremium = false;
  int _usageCount = 0;

  bool get isPremium => _isPremium;
  int get remainingTrial => _trialLimit - _usageCount;

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    _usageCount = prefs.getInt(_usageCountKey) ?? 0;
    notifyListeners();
  }

  Future<void> incrementUsage() async {
    if (_isPremium) return;
    final prefs = await SharedPreferences.getInstance();
    _usageCount++;
    await prefs.setInt(_usageCountKey, _usageCount);
    notifyListeners();
  }

  Future<void> upgradeToPremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = true;
    await prefs.setBool(_premiumKey, true);
    notifyListeners();
  }
}
