import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang Scaffold
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        backgroundColor: Colors.white, // Latar belakang AppBar
        foregroundColor: Colors.black, // Warna teks dan ikon AppBar
        elevation: 1,
      ),
      body: Container(
        color: Colors.white, // Latar belakang konten
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Layanan keluhan pengguna',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.phone, size: 28, color: Colors.black),
                SizedBox(width: 12),
                Text('+23 623808', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.email, size: 28, color: Colors.black),
                SizedBox(width: 12),
                Text('tukangku@workmail.com', style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
