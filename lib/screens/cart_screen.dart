import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color cardBackground = const Color(0xFFF7F1FB);
  final Color iconColor = const Color(0xFF6A4BBC);
  final Color subtitleColor = const Color(0xFF9E9E9E);

  List<Map<String, String>> cartItems = [
    {
      "title": "Section Air",
      "subtitle": "Pak darsono - Spesialis pompa air",
      "price": "Rp.0",
    },
    {
      "title": "Section Listrik",
      "subtitle": "Pak Imam - Ahli kelistrikan",
      "price": "Rp.50.000",
    },
    {
      "title": "Section Bangunan",
      "subtitle": "Pak Edi - Tukang bangunan",
      "price": "Rp.100.000",
    },
  ];

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item berhasil dihapus'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeAllItems() {
    setState(() {
      cartItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua item dihapus'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Keranjang Pesanan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions:
            cartItems.isNotEmpty
                ? [
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.redAccent,
                    ),
                    tooltip: "Hapus Semua",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Hapus semua item?"),
                              content: const Text(
                                "Apakah kamu yakin ingin menghapus semua item di keranjang?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    _removeAllItems();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Hapus Semua"),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ]
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            cartItems.isEmpty
                ? const Center(
                  child: Text(
                    "Keranjang kosong",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Dismissible(
                      key: Key(item["title"] ?? index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeItem(index),
                      child: _buildCartItem(
                        title: item["title"] ?? "---",
                        subtitle: item["subtitle"] ?? "",
                        price: item["price"] ?? "",
                        onDelete: () => _removeItem(index),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildCartItem({
    required String title,
    required String subtitle,
    required String price,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(
                title == "---" ? Icons.person : Icons.handyman,
                size: 28,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: TextStyle(color: subtitleColor, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.redAccent,
                  onPressed: onDelete,
                  tooltip: "Hapus item",
                ),
                if (price.isNotEmpty)
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
