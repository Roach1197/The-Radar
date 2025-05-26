import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text("Upgrade to Premium"),
            subtitle: const Text("Remove limits, unlock AI speed & tools"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, "/paywall"),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("System toggle placeholder (future support)"),
            value: isDark,
            onChanged: null,
          ),
          SwitchListTile(
            title: const Text("Ad Display"),
            subtitle: const Text("Show minimal banner ads (optional)"),
            value: true,
            onChanged: (val) {
              // You can implement ad toggle logic here
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text("Affiliate Links"),
            subtitle: const Text("Support the project by checking these tools"),
            onTap: () {
              // Optional: open your affiliate landing page
              // launchUrlString('https://yourdomain.com/affiliates');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About RareCoinRadar"),
            subtitle: const Text("Version 1.0.0 • Flutter + Flask + Stripe"),
          ),
        ],
      ),
    );
  }
}
