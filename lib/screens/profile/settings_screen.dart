import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubes_1/screens/HelpScreen.dart';
// import 'notifikasi_screen.dart';
import '../../theme_notifier.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Akun',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.notifications_none,
            title: 'Notifikasi',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.credit_card,
            title: 'Pembayaran',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.brightness_4_outlined,
            title: 'Tema',
            onTap: () {
              final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
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
            title: 'Bantuan',
            onTap: ()  {
              Navigator.push(context, 
              MaterialPageRoute(
                builder: (context) => const HelpScreen(),
              ));
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang',
            onTap: () {},
          ),
          const Divider(thickness: 1, height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Tindakan saat menghapus akun
                },
                child: const Text(
                  'Hapus Akun',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: const Border(bottom: BorderSide(width: 0.5, color: Colors.black54)),
    );
  }
}
