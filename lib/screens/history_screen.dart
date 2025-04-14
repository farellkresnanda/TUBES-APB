import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> orders = [
      {"tanggal": "20 Maret 2025", "layanan": "Bangunan"},
      {"tanggal": "18 Maret 2025", "layanan": "Kelistrikan"},
      {"tanggal": "15 Maret 2025", "layanan": "Air"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(orders[index]["layanan"]!),
              subtitle: Text("Tanggal: ${orders[index]["tanggal"]}"),
            ),
          );
        },
      ),
    );
  }
}
