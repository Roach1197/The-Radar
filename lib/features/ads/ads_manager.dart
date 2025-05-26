// lib/utils/ads_manager.dart
// Full logic for ad integration and hooks (Flutter-ready)

import 'package:flutter/material.dart';

// Enum to simulate ad status and user premium
enum AdStatus { notLoaded, loaded, error }

class AdsManager with ChangeNotifier {
  AdStatus _status = AdStatus.notLoaded;
  bool _isPremiumUser = false;

  AdStatus get status => _status;
  bool get isPremium => _isPremiumUser;

  void markAsPremium() {
    _isPremiumUser = true;
    notifyListeners();
  }

  void resetPremium() {
    _isPremiumUser = false;
    notifyListeners();
  }

  void simulateAdLoadSuccess() {
    _status = AdStatus.loaded;
    notifyListeners();
  }

  void simulateAdError() {
    _status = AdStatus.error;
    notifyListeners();
  }

  void resetAdStatus() {
    _status = AdStatus.notLoaded;
    notifyListeners();
  }
}

// Simple Ad Banner (placeholder or real SDK logic)
class AdBanner extends StatelessWidget {
  final bool isVisible;
  const AdBanner({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text("[Ad Placeholder: Banner]",
            style: TextStyle(color: Colors.black54)),
      ),
    );
  }
}

// Premium lock widget
class PremiumLock extends StatelessWidget {
  final String title;
  final VoidCallback onUpgrade;

  const PremiumLock({
    super.key,
    required this.title,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("This feature is locked. Upgrade to Premium to access."),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.lock_open),
              label: const Text("Upgrade Now"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            )
          ],
        ),
      ),
    );
  }
}

