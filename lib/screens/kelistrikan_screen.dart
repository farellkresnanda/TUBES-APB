import 'package:flutter/material.dart';

class KelistrikanScreen extends StatelessWidget {
  const KelistrikanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Kelistrikan'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electrical_services, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Ini halaman Kelistrikan',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
