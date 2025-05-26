import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/listing_output.dart';
import '../utils/constants.dart';
import '../features/paywall/paywall_screen.dart';
import '../widgets/ad_banner.dart';

class FullReportPage extends StatefulWidget {
  const FullReportPage({super.key});

  @override
  State<FullReportPage> createState() => _FullReportPageState();
}

class _FullReportPageState extends State<FullReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _supplyCostController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;
  bool _premiumUnlocked = false;
  Map<String, dynamic>? _result;

  Future<void> _generateReport() async {
    if (!_premiumUnlocked) {
      final unlocked = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      if (unlocked != true) return;
      setState(() => _premiumUnlocked = true);
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse("http://174.138.37.32:5050/ebay-listing");
      final body = {
        "item_title": _titleController.text,
        "purchase_price": _priceController.text,
        "supply_cost": _supplyCostController.text,
        "weight_oz": _weightController.text,
        "weight_lbs": "0",
        "condition": "Used",
        "notes": "Auto-generated listing.",
        "shipping_type": "first_class",
        "buyer_pays_shipping": true,
        "promo_rate": "0"
      };

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() => _result = json.decode(response.body));
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _supplyCostController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Full Report Generator")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: "Item Title",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (val) => val!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: "Purchase Price",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _supplyCostController,
                                  decoration: const InputDecoration(
                                    labelText: "Supply Cost",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: "Weight (oz)",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _generateReport,
                                  icon: const Icon(Icons.analytics),
                                  label: const Text("Generate Full Report"),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_result != null) ListingOutput(data: _result!)
                        ],
                      ),
                    ),
            ),
          ),
          const AdBanner(bannerText: "Ad Banner Placeholder (Full Report)"),
        ],
      ),
    );
  }
}

