import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFEB3B); // Warna utama kuning TukangKu
    const darkTextColor = Color(0xFF2D2D2D); // Warna teks gelap

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Pusat Bantuan'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFEB3B), Color(0xFFFFF176)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, apa ada yang bisa dibantu?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                SearchBar(),
              ],
            ),
          ),
          const AlertBox(),
          const SizedBox(height: 20),
          const HelpSection(),
          const SizedBox(height: 20),
          const ContactSection(),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cari',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class AlertBox extends StatelessWidget {
  const AlertBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9C4),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
          Icon(Icons.campaign, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Jika akun Anda bermasalah, segera hubungi layanan pengguna kami.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpSection extends StatelessWidget {
  const HelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Pertanyaan yang Sering Diajukan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        ...[
          "[Akun] Bagaimana cara mengubah nomor telepon?",
          "[Pembayaran] Bagaimana cara melakukan pembayaran digital?",
          "[Tukang] Bagaimana saya memilih tukang yang terpercaya?",
          "[Tracking] Mengapa lokasi tukang tidak muncul?",
          "[Rating] Bagaimana cara memberikan ulasan setelah pekerjaan selesai?",
        ].map(
          (faq) => ListTile(
            title: Text(faq, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "HUBUNGI KAMI",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.email, color: Colors.black54),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Kontak kami melalui email\ntukangku@gmail.com",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.black54),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Telepon Kami\nJam Operasional 07.00 WIB - 21.59 WIB",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
