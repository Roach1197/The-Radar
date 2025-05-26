import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../utils/stripe_config.dart';

class StripeCheckoutWidget extends StatelessWidget {
  final String plan;
  const StripeCheckoutWidget({super.key, this.plan = "basic"});

  void _launchStripeCheckout() {
    final sessionUrl = Uri.parse(
      "https://checkout.stripe.com/pay/$stripePublishableKey?prefilled_plan=$plan"
    );
    html.window.open(sessionUrl.toString(), "_blank");
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.lock),
      label: const Text("Unlock Premium"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: _launchStripeCheckout,
    );
  }
}
