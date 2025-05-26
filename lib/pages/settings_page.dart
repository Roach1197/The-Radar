import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Upgrade to Premium"),
            subtitle: const Text("Unlock unlimited listings and advanced reports"),
            trailing: const Icon(Icons.lock_open),
            onTap: () => Navigator.pushNamed(context, '/paywall'),
          ),
          SwitchListTile(
            title: const Text("Show Ads"),
            subtitle: const Text("Optional placeholder for ad toggle"),
            value: true,
            onChanged: (_) {},
          ),
          const Divider(),
          const ListTile(
            title: Text("App Version"),
            subtitle: Text("v1.0.0"),
          ),
          const ListTile(
            title: Text("Powered by"),
            subtitle: Text("Flutter + Flask + OpenAI"),
          ),
        ],
      ),
    );
  }
}
