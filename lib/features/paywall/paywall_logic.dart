// lib/features/paywall/paywall_logic.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaywallManager {
  static const _keyPremiumUser = "isPremium";

  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPremiumUser) ?? false;
  }

  static Future<void> activatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremiumUser, true);
  }

  static Future<void> resetPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPremiumUser);
  }

  static Future<void> showPaywallDialog(BuildContext context) async {
    final isPremium = await isPremiumUser();
    if (isPremium) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upgrade to Premium"),
        content: const Text(
            "Unlock unlimited listings, full SEO reports, and remove ads."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Maybe Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              await activatePremium();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Premium unlocked!")),
              );
            },
            child: const Text("Upgrade Now"),
          ),
        ],
      ),
    );
  }
}

