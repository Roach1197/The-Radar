import 'package:flutter/material.dart';

class ProfitBreakdown extends StatelessWidget {
  final Map<String, dynamic> result;
  const ProfitBreakdown({super.key, required this.result});

  Color getBadgeColor(String badge) {
    switch (badge) {
      case 'good':
        return Colors.green.shade400;
      case 'okay':
        return Colors.yellow.shade600;
      default:
        return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final margin = result['margin'] ?? 0.0;
    final badge = result['badge'] ?? 'low';
    final category = result['category'] ?? 'Other';

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Profit Breakdown",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Chip(
                  label: Text(
                    "Margin: ${margin.toStringAsFixed(2)}%",
                    style: const TextStyle(color: Colors.black),
                  ),
                  backgroundColor: getBadgeColor(badge),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Resale Price + Category
            Text("Category: $category",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text("Resale Estimate: \$${(result['resale_avg'] ?? 0).toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 14)),

            const SizedBox(height: 16),

            // Animated Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                height: 10,
                width: double.infinity,
                color: Colors.grey[700],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (margin / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: getBadgeColor(badge),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Detailed rows
            breakdownRow("eBay Fee", result['fees']?['ebay_fee']),
            breakdownRow("Shipping", result['fees']?['shipping_fee']),
            breakdownRow("Promoted Fee", result['fees']?['promoted_fee']),
            breakdownRow("Purchase Cost", result['costs']?['purchase']),
            breakdownRow("Supplies", result['costs']?['supplies']),
            breakdownRow("Total Cost", result['total_cost']),
            breakdownRow("Net Profit", result['profit'], isFinal: true),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if ((result['resale_high'] ?? 0) - (result['resale_low'] ?? 0) > 10)
                  tag("Volatile Market", Colors.orange),
                if ((result['listing'] ?? '').toLowerCase().contains("no returns accepted"))
                  tag("Top Seller Format", Colors.purple),
                if ((result['listing'] ?? '').toLowerCase().contains("silver") ||
                    (result['listing'] ?? '').toLowerCase().contains("graded"))
                  tag("SEO-Optimized", Colors.blue),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget breakdownRow(String label, dynamic amount, {bool isFinal = false}) {
    final style = TextStyle(
      fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
      color: isFinal ? Colors.greenAccent : Colors.white,
    );
    final formatted = amount != null ? "\$${(amount as num).toStringAsFixed(2)}" : "-";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatted, style: style),
        ],
      ),
    );
  }

  Widget tag(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
