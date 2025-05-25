import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        elevation: 1,
      ),
      body: Container(
        color: Colors.white,
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
                Text('+62 82124873745', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.email, size: 28, color: Colors.black),
                SizedBox(width: 12),
                Text('tukangku@gmail.com', style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
