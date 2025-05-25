import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/screens/HelpScreen.dart'; // Update with your path
import 'MessageScreen.dart';

const Color primaryYellow = Color(0xFFFFB800);
const Color secondaryYellow = Color(0xFFFFD976);

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> userList = [];
  bool isLoading = true;
  String? currentUserRole;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    fetchUserList();
  }

  Future<void> fetchUserList() async {
    try {
      setState(() => isLoading = true);
      currentUserId = supabase.auth.currentUser?.id ?? '';

      if (currentUserId.isEmpty) {
        throw Exception('User not logged in');
      }

      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', currentUserId)
          .maybeSingle();

      final currentRole = (userData?['role'] as String?)?.toLowerCase()?.trim();
      if (currentRole == null) {
        throw Exception('Role user tidak ditemukan');
      }

      currentUserRole = currentRole;
      final targetRole = currentRole == 'tukang' ? 'pelanggan' : 'tukang';

      final response = await supabase
          .from('users')
          .select('id, full_name, phone, role, updated_at')
          .ilike('role', targetRole)
          .neq('id', currentUserId);

      setState(() {
        userList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kotak Pesan'),
        backgroundColor: primaryYellow,
      ),
      body: Column(
        children: [
          // Pilihan Fitur Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.help, color: Colors.green),
                title: const Text('Bantuan'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
              ),
              const Divider(height: 1),
            ],
          ),

          // Main chat list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : userList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada ${currentUserRole == 'tukang' ? 'Pelanggan' : 'Tukang'} yang tersedia',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                final lastSeen = user['updated_at'] != null
                    ? DateTime.parse(user['updated_at']).toLocal()
                    : null;

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          user['full_name']?[0] ?? '?',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(user['full_name'] ?? 'Pengguna'),
                      subtitle: Text(
                        user['phone'] ?? 'No telepon tidak tersedia',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: lastSeen != null
                          ? Text(
                        '${lastSeen.hour}:${lastSeen.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              receiverId: user['id'],
                              receiverName: user['full_name'] ?? 'Pengguna',
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}