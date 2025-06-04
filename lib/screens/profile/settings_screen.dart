import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubes_1/screens/HelpScreen.dart';
import '../../theme_notifier.dart';
import 'package:tubes_1/screens/profile/profile_screen.dart';
import 'package:tubes_1/screens/profile/payment_screen.dart';
import 'package:tubes_1/screens/profile/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan'), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.person_outline,
            iconColor: Colors.blue,
            title: 'Akun',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications_none,
            iconColor: Colors.deepOrange,
            title: 'Notifikasi',
            onTap: () {
              // Arahkan ke layar notifikasi bila ada
            },
          ),
          _buildMenuItem(
            icon: Icons.credit_card,
            iconColor: Colors.green,
            title: 'Pembayaran',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.brightness_4_outlined,
            iconColor: Colors.purple,
            title: 'Tema',
            onTap: () {
              final themeNotifier = Provider.of<ThemeNotifier>(
                context,
                listen: false,
              );
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Pilih Tema'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Terang'),
                          onTap: () {
                            themeNotifier.toggleTheme(false);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Gelap'),
                          onTap: () {
                            themeNotifier.toggleTheme(true);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            iconColor: Colors.teal,
            title: 'Bantuan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            iconColor: Colors.indigo,
            title: 'Tentang',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const Divider(thickness: 1, height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                'Hapus Akun',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Tambahkan aksi hapus akun di sini
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: const Border(
        bottom: BorderSide(width: 0.5, color: Colors.black12),
      ),
    );
  }
}
