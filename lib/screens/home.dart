import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController supplyCostController = TextEditingController();
  final TextEditingController promoRateController = TextEditingController();
  final TextEditingController weightLbsController = TextEditingController();
  final TextEditingController weightOzController = TextEditingController();

  bool buyerPaysShipping = false;
  String shippingType = 'first_class';

  bool isLoading = false;
  Map<String, dynamic>? result;

  Future<void> calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      result = null;
    });

    final uri = Uri.parse('https://yourdomain.com/ebay-listing');
    final body = {
      'item_title': titleController.text,
      'condition': conditionController.text,
      'notes': notesController.text,
      'purchase_price': purchasePriceController.text,
      'supply_cost': supplyCostController.text,
      'promo_rate': promoRateController.text,
      'weight_lbs': weightLbsController.text,
      'weight_oz': weightOzController.text,
      'buyer_pays_shipping': buyerPaysShipping ? 'on' : '',
      'shipping_type': shippingType
    };

    try {
      final response = await http.post(uri, body: body);
      if (response.statusCode == 200) {
        setState(() => result = json.decode(response.body));
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  Widget resultView() {
    if (result == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profit Margin: ${result!["profit_margin"]}%', style: const TextStyle(color: Colors.greenAccent, fontSize: 18)),
          Text('Estimated Resale: \$${result!["resale_price"]}', style: const TextStyle(color: Colors.white)),
          const Divider(color: Colors.white24),
          Text('Generated Listing:', style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SelectableText(result!["result"], style: const TextStyle(color: Colors.white70, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eBay Listing Generator"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Enter Product Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(controller: titleController, decoration: const InputDecoration(labelText: 'Item Title'), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(controller: conditionController, decoration: const InputDecoration(labelText: 'Condition')),
              TextFormField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes')),
              Row(
                children: [
                  Checkbox(value: buyerPaysShipping, onChanged: (val) => setState(() => buyerPaysShipping = val!)),
                  const Text("Buyer pays shipping"),
                ],
              ),
              DropdownButtonFormField<String>(
                value: shippingType,
                decoration: const InputDecoration(labelText: 'Shipping Type'),
                items: const [
                  DropdownMenuItem(value: 'first_class', child: Text('First Class')),
                  DropdownMenuItem(value: 'ground_advantage', child: Text('Ground Advantage')),
                  DropdownMenuItem(value: 'priority_flat', child: Text('Priority Flat')),
                ],
                onChanged: (val) => setState(() => shippingType = val!),
              ),
              TextFormField(controller: purchasePriceController, decoration: const InputDecoration(labelText: 'Purchase Price'), keyboardType: TextInputType.number),
              TextFormField(controller: supplyCostController, decoration: const InputDecoration(labelText: 'Supply Cost'), keyboardType: TextInputType.number),
              TextFormField(controller: promoRateController, decoration: const InputDecoration(labelText: 'Promoted Rate (%)'), keyboardType: TextInputType.number),
              TextFormField(controller: weightLbsController, decoration: const InputDecoration(labelText: 'Weight (lbs)'), keyboardType: TextInputType.number),
              TextFormField(controller: weightOzController, decoration: const InputDecoration(labelText: 'Weight (oz)'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: isLoading ? null : calculate,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Generate Report"),
              ),
              const SizedBox(height: 24),
              resultView(),
            ],
          ),
        ),
      ),
    );
  }
}
