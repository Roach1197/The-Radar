import 'package:flutter/material.dart';

class AdBanner extends StatelessWidget {
  final String bannerText;
  const AdBanner({super.key, required this.bannerText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.orange.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.ad_units, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Text(bannerText, style: const TextStyle(color: Colors.deepOrange)),
        ],
      ),
    );
  }
}
