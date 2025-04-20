import 'package:flutter/material.dart';
import 'MessageScreen.dart';
import 'HelpScreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String selectedFeature = 'Kotak Pesan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Pilihan Fitur',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFeatureIcon('Kotak Pesan', Icons.mail, Colors.amber),
                const SizedBox(width: 20),
                _buildFeatureIcon('Pusat Bantuan', Icons.help_outline, Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedFeature == 'Kotak Pesan'
                  ? _buildChatList(context)
                  : const HelpScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(String label, IconData icon, Color color) {
    final isSelected = selectedFeature == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFeature = label;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
            ),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label == 'Kotak Pesan' ? 'Kotak Pesan' : 'Bantuan',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    final List<String> chatNames = List.generate(5, (_) => 'Pak Darsono - Tukang');

    return ListView.builder(
      itemCount: chatNames.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessageScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_circle, size: 48),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Pak darsono - Tukang',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        Text('...', style: TextStyle(fontSize: 12)),
                        SizedBox(height: 2),
                        Text('Lokasi', style: TextStyle(fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
          ],
        );
      },
    );
  }
}
