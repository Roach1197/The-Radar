import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RareCoinRadar Home'),
      ),
      body: const Center(
        child: Text(
          'Welcome to RareCoinRadar!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
