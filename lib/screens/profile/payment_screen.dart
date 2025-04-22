import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  final Color darkText = const Color(0xFF333333);
  final Color primaryYellow = const Color(0xFFFFB800);
  final Color lightGreen = const Color(0xFFE6F9EA); // background button
  final Color greenText = const Color(0xFF23B35F); // text/button label
  final Color white = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text(
          'Atur metode pembayaran',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tambah metode',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ..._buildPaymentItemList([
            PaymentItem("LinkAja", "", "Hubungkan", "assets/linkaja.png"),
            PaymentItem(
              "Kartu kredit atau debit",
              "Visa, Mastercard, AMEX, dan JCB",
              "Tambah",
              "assets/card.png",
            ),
            PaymentItem(
              "Kantong Jago",
              "Hubungkan rek. Bank Jago kamu",
              "Hubungkan",
              "assets/jago.png",
            ),
            PaymentItem(
              "BRI Direct Debit",
              "Terima kartu Mastercard & GPN",
              "Tambah",
              "assets/bri.png",
            ),
            PaymentItem(
              "blu by BCA Digital",
              "Bayar dari bluAccount",
              "Tambah",
              "assets/blu.png",
            ),
          ]),
          const SizedBox(height: 30),
          const Divider(),
          const Text(
            'Metode pembayaran lainnya',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildCashOption(),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentItemList(List<PaymentItem> items) {
    return items.map((item) => _buildPaymentItem(item)).toList();
  }

  Widget _buildPaymentItem(PaymentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Image.asset(item.iconPath, width: 32, height: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryYellow, // <--- warna kuning
              foregroundColor: Colors.white, // teks putih biar kontras
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {},
            child: Text(item.actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildCashOption() {
    return Row(
      children: [
        Icon(
          Icons.payments_outlined,
          size: 32,
          color: primaryYellow,
        ), // <- kuning
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Tunai", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Siapin uang pas ya, biar gak usah repot nungguin kembalian.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaymentItem {
  final String title;
  final String subtitle;
  final String actionLabel;
  final String iconPath;

  PaymentItem(this.title, this.subtitle, this.actionLabel, this.iconPath);
}
