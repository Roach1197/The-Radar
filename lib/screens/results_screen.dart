import 'package:flutter/material.dart';
import 'package:rarecoinradar_app/widgets/listing_output.dart';
import 'package:rarecoinradar_app/widgets/profit_breakdown.dart';
import 'package:rarecoinradar_app/constants.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultsScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final String listingText = resultData["listing"] ?? "";
    final double profitMargin = resultData["margin"]?.toDouble() ?? 0.0;

    String badge = "low";
    if (profitMargin >= 30) badge = "good";
    else if (profitMargin >= 15) badge = "okay";

    return Scaffold(
      appBar: AppBar(
        title: const Text("eBay Listing Results"),
        backgroundColor: kDarkBackground,
      ),
      backgroundColor: kBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags and status
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _statusTag("AI Confidence: High ✅", kIndigo),
                if (badge == "good")
                  _statusTag("High Profit Potential", kGreen)
                else if (badge == "okay")
                  _statusTag("Moderate Profit Margin", kYellow)
                else
                  _statusTag("Low Profit Warning", kRed),
                if ((resultData["resale_high"] ?? 0) - (resultData["resale_low"] ?? 0) > 10)
                  _statusTag("Volatile Market", kOrange),
                if ((listingText).toLowerCase().contains("silver") ||
                    (listingText).toLowerCase().contains("graded"))
                  _statusTag("SEO-Optimized", kBlue),
                if ((listingText).toLowerCase().contains("no returns"))
                  _statusTag("Top Seller Format", kPurple),
              ],
            ),
            const SizedBox(height: 20),
            // Profit Bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                widthFactor: profitMargin.clamp(0, 100) / 100,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: badge == "good"
                        ? Colors.green
                        : badge == "okay"
                            ? Colors.yellow
                            : Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("Profit Margin: ${profitMargin.toStringAsFixed(1)}%",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),

            // Breakdown widget
            ProfitBreakdown(data: resultData),
            const SizedBox(height: 24),

            // Listing output
            ListingOutputBox(resultText: listingText),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}
