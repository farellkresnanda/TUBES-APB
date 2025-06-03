import 'package:flutter/material.dart';
import 'package:tubes_1/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class pesananInvoice extends StatelessWidget {
  final String alamat;
  final String kategori;
  final String deskripsi;
  final int jumlah_tukang;
  final int jam_kerja;

  const pesananInvoice({
    super.key,
    this.alamat = '',
    this.kategori = '',
    this.deskripsi = '',
    this.jumlah_tukang = 1,
    this.jam_kerja = 1,
  });

  Future<void> cekAlamat() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('alamat_tersimpan')
          .select('*')
          .eq('alamat', alamat);
      if (response.isEmpty) {
        await supabase.from('alamat_tersimpan').insert({'alamat': alamat});
      }
    } catch (error) {
      print('Error saat mengirim pesanan: $error');
    }
  }

  String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  int hitungTotalHarga() {
    final hargaPerJam = {
      'Tukang Bangunan': 35000,
      'Tukang Listrik': 40000,
      'Tukang Air': 38000,
    };

    final harga = hargaPerJam[kategori] ?? 35000;
    final total = harga * jam_kerja * jumlah_tukang;
    return total;
  }

  Future<void> submitPesanan(BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('pesanan').insert({
            'kategori': kategori,
            'alamat': alamat,
            'jumlah_tukang': jumlah_tukang,
            'jam_kerja': jam_kerja,
            'deskripsi': deskripsi,
            'proses': 'diproses',
            'user_id': supabase.auth.currentUser?.id,
            'total_harga': hitungTotalHarga(),
          }).select();
      cekAlamat();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  const HomeScreen(successMessage: "Tukang Berhasil Dipesan"),
        ),
      );
    } catch (error) {
      print('Error saat mengirim pesanan: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengirim pesanan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                color: Colors.orange,
                width: double.infinity,
                child: Column(
                  children: const [
                    Text(
                      "Cari tukang?, TukangKu Solusinya!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "TukangKu",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Mitra Terpercaya Penyedia Tenaga Konstruksi.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Box Ringkasan
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ringkasan pembayaran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(Icons.location_on),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Lokasi sudah ditentukan",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _InvoiceRow(
                            title: "Harga",
                            amount: formatRupiah(hitungTotalHarga()),
                          ),
                          _InvoiceRow(
                            title: "Biaya perjalanan",
                            amount: formatRupiah(20000),
                          ),
                          _InvoiceRow(
                            title: "Biaya asuransi tukang",
                            amount: formatRupiah(10000),
                          ),
                          const _InvoiceRow(title: "Diskon", amount: "Rp0"),
                          const Divider(),
                          _InvoiceRow(
                            title: "Total pembayaran",
                            amount: formatRupiah(
                              hitungTotalHarga() + 20000 + 10000,
                            ),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol
              ElevatedButton(
                onPressed: () {
                  submitPesanan(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: const Text("Panggil Tukang"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String title;
  final String amount;
  final bool isBold;

  const _InvoiceRow({
    required this.title,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
