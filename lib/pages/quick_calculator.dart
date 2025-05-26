import 'package:flutter/material.dart';

class QuickCalculatorPage extends StatelessWidget {
  const QuickCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Calc')),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text("Quick Calculator goes here"),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade300,
            child: const Center(
              child: Text(
                'Ad Banner Placeholder (Quick Calc)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
