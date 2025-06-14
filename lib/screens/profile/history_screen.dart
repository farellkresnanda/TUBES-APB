import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPesanan() async {
    try {
      final response = await supabase
          .from('pesanan')
          .select()
          .eq('proses', 'selesai');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print(stackTrace);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPesanan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('Tidak ada pesanan.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(
                    orders[index]["kategori"] ?? "Layanan tidak diketahui",
                  ),
                  subtitle: Text(
                    "Tanggal: ${orders[index]["created_at"] ?? "-"}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
