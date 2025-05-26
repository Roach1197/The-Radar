import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pages/home_page.dart';
import 'pages/quick_calculator.dart';
import 'pages/full_report.dart';
import 'pages/settings_page.dart';
import 'pages/success_screen.dart';
import 'pages/cancel_screen.dart';
import 'features/paywall/paywall_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'widgets/listing_output.dart';

void main() {
  runApp(const RareCoinRadarApp());
}

class RareCoinRadarApp extends StatelessWidget {
  const RareCoinRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RareCoinRadar',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routes: {
        '/': (_) => const AppShell(),
        '/paywall': (_) => const PaywallScreen(),
        '/success': (_) => const SuccessScreen(),
        '/cancel': (_) => const CancelScreen(),
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    QuickCalculatorPage(),
    FullReportPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.grey.shade900,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Quick Calc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Full Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
