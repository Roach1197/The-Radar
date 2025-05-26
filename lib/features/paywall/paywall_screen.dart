// lib/features/paywall/paywall_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  Future<void> _startSubscriptionFlow(BuildContext context) async {
    final response = await http.post(
      Uri.parse("http://174.138.37.32:5050/api/create-checkout-session"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "plan": "price_basic",  // Replace with your actual Stripe price ID
        "success_url": "https://rarecoinradar.com/success",
        "cancel_url": "https://rarecoinradar.com/cancel",
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body["url"] != null) {
      final url = body["url"];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Redirecting to payment...")),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      // Open browser (web only)
      // For mobile you'd use url_launcher package
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WebViewStripe(url: url),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${body["error"] ?? "Unknown error"}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.lock_open_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              "Unlock Full Access",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Upgrade now to remove all limits, get faster listing generation, and eliminate ads.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildPlanCard(
              context,
              title: "Free Plan",
              price: "\$0/month",
              features: const [
                "• 5 listings/day",
                "• Ads enabled",
                "• Basic reports",
              ],
              selected: false,
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              context,
              title: "Premium Plan",
              price: "\$9.99/month",
              features: const [
                "✓ Unlimited listings",
                "✓ No ads",
                "✓ Priority API access",
                "✓ GPT-powered listing AI",
                "✓ Export to PDF/CSV/JSON",
              ],
              selected: true,
              highlight: true,
              onSubscribe: () => _startSubscriptionFlow(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool selected,
    bool highlight = false,
    VoidCallback? onSubscribe,
  }) {
    final color = highlight ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200;
    final textColor = highlight ? Colors.white : Colors.black87;
    return Card(
      color: highlight ? Theme.of(context).colorScheme.secondaryContainer : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: highlight ? 8 : 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                )),
            const SizedBox(height: 4),
            Text(price,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.9),
                )),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(f, style: TextStyle(color: textColor.withOpacity(0.95))),
                )),
            if (onSubscribe != null) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onSubscribe,
                  icon: const Icon(Icons.payment),
                  label: const Text("Subscribe Now"),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// Placeholder WebView screen (to replace with real webview support later)
class WebViewStripe extends StatelessWidget {
  final String url;
  const WebViewStripe({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Page")),
      body: Center(child: Text("Redirect to:\n$url", textAlign: TextAlign.center)),
    );
  }
}
