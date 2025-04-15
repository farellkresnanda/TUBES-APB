import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSwitchTile(
              title: 'Mode Gelap',
              value: isDarkMode,
              onChanged: (val) => themeNotifier.toggleTheme(val),
              icon: Icons.dark_mode,
            ),
            _buildSwitchTile(
              title: 'Notifikasi',
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
              icon: Icons.notifications_active,
            ),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.indigo),
              title: const Text('Pusat Bantuan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PusatBantuanPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: Text(title),
        value: value,
        secondary: Icon(icon, color: Colors.deepPurple),
        onChanged: onChanged,
      ),
    );
  }
}

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pusat Bantuan")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Jika Anda mengalami kendala, silakan hubungi kami di support.tukangku@gmail.com",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
