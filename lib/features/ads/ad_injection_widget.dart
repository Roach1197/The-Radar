// lib/features/ads/ad_injection_widget.dart
import 'package:flutter/material.dart';

class AdInjectionWidget extends StatelessWidget {
  final bool premium;
  const AdInjectionWidget({super.key, required this.premium});

  @override
  Widget build(BuildContext context) {
    if (premium) return const SizedBox.shrink(); // Hide ads if user is premium

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        children: const [
          Text(
            "Ad Preview Area",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "This is a placeholder for future AdMob or banner network ads.\nUpgrade to Premium to hide all ads.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

