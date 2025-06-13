import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFEB3B); // kuning utama
    const darkTextColor = Color(0xFF2D2D2D); // warna teks gelap

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Tentang TukangKu",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          const SectionTitle(title: "TANTANGAN KAMI"),
          const SizedBox(height: 8),
          const Text(
            "Akses jasa tukang yang belum merata di Indonesia",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Di banyak daerah di Indonesia, masyarakat masih kesulitan dalam menemukan tukang bangunan yang handal dan terpercaya. Proses pencarian yang masih bergantung pada metode konvensional sering kali memakan waktu dan tidak menjamin kualitas layanan yang didapat. Sementara itu, para tukang pun kerap kali kesulitan mendapatkan akses ke pasar yang lebih luas karena keterbatasan digitalisasi.",
            style: TextStyle(fontSize: 16, height: 1.6, color: darkTextColor),
          ),
          const SizedBox(height: 32),

          const SectionTitle(title: "MISI KAMI"),
          const SizedBox(height: 8),
          const Text(
            "Menghubungkan kebutuhan dan keahlian dengan teknologi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Kami ingin merobohkan tembok penghalang antara pengguna yang membutuhkan jasa perbaikan rumah dan para tukang profesional yang memiliki keterampilan. Melalui aplikasi TukangKu, kami menyediakan platform digital yang mudah diakses, transparan, dan efisien dalam menghubungkan pengguna dengan tukang terdekat berdasarkan keahlian dan ulasan pelanggan.",
            style: TextStyle(fontSize: 16, height: 1.6, color: darkTextColor),
          ),
          const SizedBox(height: 12),
          const Text(
            "Dengan berbagai fitur seperti pencarian tukang berdasarkan kategori, chat langsung, pelacakan real-time, estimasi biaya, serta sistem rating dan ulasan, TukangKu hadir sebagai solusi modern untuk layanan konstruksi yang lebih profesional dan terpercaya.",
            style: TextStyle(fontSize: 16, height: 1.6, color: darkTextColor),
          ),
          const SizedBox(height: 40),

          const Divider(height: 40, thickness: 1.2),
          const Text(
            "Hubungi Kami",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.phone, color: darkTextColor),
              SizedBox(width: 10),
              Text(
                "+62 82124873745",
                style: TextStyle(fontSize: 16, color: darkTextColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.email, color: darkTextColor),
              SizedBox(width: 10),
              Text(
                "tukangku@gmail.com",
                style: TextStyle(fontSize: 16, color: darkTextColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFFEB3B),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
