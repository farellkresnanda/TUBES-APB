import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: const Center(
        child: Text(
          'Ini halaman bantuan.\nSilakan hubungi tim support kami.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
