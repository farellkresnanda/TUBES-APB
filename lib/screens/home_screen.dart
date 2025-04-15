import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'package:tubes_1/screens/login_screen.dart';
import 'package:tubes_1/screens/bangunan_screen.dart';
import 'package:tubes_1/screens/kelistrikan_screen.dart';
import 'package:tubes_1/screens/air_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('users')
          .select('username')
          .eq('id', user.id)
          .single();

      setState(() {
        username = response['username'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Background_1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 250,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Cari layanan...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildProfileMenu(context),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // Pastikan hanya tampil jika data sudah ada
                      Text(
                        'Hai, ${username ?? ''}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 5),
                    const Text(
                      'Pilih kebutuhan tukangmu' ,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                      _buildCategoryItem(Icons.home, 'Bangunan', () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => BangunanScreen()));
                      }),
                      _buildCategoryItem(Icons.electrical_services, 'Kelistrikan', () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => KelistrikanScreen()));
                      }),
                      _buildCategoryItem(Icons.water_drop, 'Air', () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AirScreen()));
                      }),
                    ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Toko Rekomendasi MinKang',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStoreItem('TB. Berkah Jaya', 'Bojongsoang', 5.0),
                          _buildStoreItem('TB. Mekar Abadi', 'Ciwastra', 4.8),
                          _buildStoreItem('TB. Jaya Abadi', 'Balenda', 4.5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Pesan'),
          ],
        ),
      );
    }

    /// Widget untuk Profil dengan Dropdown Menu
    Widget _buildProfileMenu(BuildContext context) {
      return PopupMenuButton<String>(
        icon: FutureBuilder(
          future: _getProfilePicture(), // Ambil URL foto profil dari Supabase
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              );
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white),
              );
            } else {
              return CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data!), // Load foto profil
              );
            }
          },
        ),
        onSelected: (String value) async {
          if (value == 'profile') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else if (value == 'history') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          } else if (value == 'settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          } else if (value == 'logout') {
            // Logout dari Supabase
            await Supabase.instance.client.auth.signOut();

            // Navigasi kembali ke halaman utama (main.dart)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'profile',
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'history',
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text('Riwayat'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'settings',
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Pengaturan'),
            ),
          ),
          const PopupMenuItem<String>(
           value: 'logout',
           child: ListTile(
             leading: Icon(Icons.logout),
             title: Text('Log Out'),
            ),
          ),
        ],
      );
    }

    /// Fungsi untuk Mengambil Foto Profil dari Supabase
    Future<String?> _getProfilePicture() async {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return null; // Jika user belum login

      final response = await supabase
          .from('users')
          .select('profile_picture') // Kolom foto profil di database
          .eq('id', userId)
          .single();

      return response['profile_picture']; // URL foto profil
    }

    /// Widget untuk Kategori Tukang
   Widget _buildCategoryItem(IconData icon, String label, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              child: Icon(icon, size: 30),
            ),
            const SizedBox(height: 5),
            Text(label),
          ],
        ),
      );
    }


    /// Widget untuk Menampilkan Toko Rekomendasi
    Widget _buildStoreItem(String name, String location, double rating) {
      return Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 80, color: Colors.grey), // Placeholder untuk gambar toko
            const SizedBox(height: 5),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(location, style: const TextStyle(color: Colors.grey)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                Text(rating.toString()),
              ],
            ),
          ],
        ),
      );
    }
}