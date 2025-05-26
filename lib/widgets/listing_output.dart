import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListingOutput extends StatelessWidget {
  final Map<String, dynamic> data;
  const ListingOutput({super.key, required this.data});

  void _copyToClipboard(BuildContext context) {
    final text = data['listing'] ?? '';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasListing = data['listing'] != null && data['listing'].toString().isNotEmpty;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Estimated Resale: \$${data['resale_price']}", style: const TextStyle(fontSize: 16)),
            Text("Net Profit: \$${data['profit']}", style: const TextStyle(fontSize: 16)),
            Text("Margin: ${data['margin']}%", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (hasListing) ...[
              const Text("AI-Generated Listing:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(data['listing'], style: const TextStyle(fontFamily: 'monospace')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy"),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Optional future export hook
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Export feature coming soon")),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Export"),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}
