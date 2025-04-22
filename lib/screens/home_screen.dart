import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tubes_1/screens/rating_dialog.dart';
import 'profile/profile_screen.dart';
import 'profile/history_screen.dart';
import 'profile/settings_screen.dart';
import 'package:tubes_1/screens/login_screen.dart';
import 'package:tubes_1/screens/Bangunan/bangunan_screen.dart';
import 'package:tubes_1/screens/Kelistrikan/kelistrikan_screen.dart';
import 'package:tubes_1/screens/Air/air_screen.dart';
import 'cart_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tubes_1/screens/ChatSection/ChatListScreen.dart';

class HomeScreen extends StatefulWidget {
  final String? successMessage;

  const HomeScreen({super.key, this.successMessage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  int _selectedIndex = 0;

 @override
  void initState() {
    super.initState();
    fetchUsername();

    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
      Future.delayed(const Duration(seconds: 3), () {
       showDialog(
          context: context,
          builder: (context) => RatingDialog(
            onRated: (rating) {
              print("User memberi rating: $rating");
              // Bisa simpan ke database, Firebase, dsb.
            },
          ),
        );
      });
    }
  }


  Future<void> fetchUsername() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response =
          await Supabase.instance.client
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
    final pages = [
      HomeScreenContent(
        username: username ?? '',
        onProfileMenu: _buildProfileMenu,
      ),
      const CartScreen(),
      const ChatListScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Pesan'),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: FutureBuilder(
        future: _getProfilePicture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            );
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            );
          } else {
            return CircleAvatar(backgroundImage: NetworkImage(snapshot.data!));
          }
        },
      ),
      onSelected: (String value) async {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'history') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        } else if (value == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        } else if (value == 'logout') {
          await Supabase.instance.client.auth.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Profil'),
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Riwayat'),
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Pengaturan'),
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
              ),
            ),
          ],
    );
  }

  Future<String?> _getProfilePicture() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final response =
        await Supabase.instance.client
            .from('users')
            .select('profile_picture')
            .eq('id', userId)
            .single();
    
    final fileName = response['profile_picture'] as String?;
    if (fileName == null) return null;
    
    final String url = Supabase.instance.client.storage.from('profilepictures').getPublicUrl(fileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$url?ts=$timestamp';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addScopedWillPopCallback(() {
    if (mounted) setState(() {});
    return Future.value(true);
    });
  }
}

class HomeScreenContent extends StatelessWidget {
  final String username;
  final Widget Function(BuildContext) onProfileMenu;

  const HomeScreenContent({
    super.key,
    required this.username,
    required this.onProfileMenu,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      Theme
                          .of(context)
                          .brightness == Brightness.light
                          ? 'assets/Background_1.png'
                          : 'assets/Background_2.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 250,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 50,
                ),
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
                    onProfileMenu(context),
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
                Text(
                  'Hai, $username!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Ayo pilih kebutuhan tukangmu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryItem(Icons.home, 'Bangunan', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BangunanScreen(),
                        ),
                      );
                    }),
                    _buildCategoryItem(
                      Icons.electrical_services,
                      'Kelistrikan',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KelistrikanScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCategoryItem(Icons.water_drop, 'Air', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AirScreen()),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Toko Rekomendasi MinKang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                    _buildStoreItem(
                    'TB. Sinar Saluyu Putra SSP',
                    'Bojongsoang',
                    5.0,
                    'TB. Sinar Saluyu Putra SSP Bojongsoang',
                    'assets/sinar_saluyu.jpg',
                  ),
                  _buildStoreItem(
                    'TB. Surya Jaya Putra',
                    'Bojongsoang',
                    4.7,
                    'Tb Surya Jaya Putra Bojongsoang',
                    'assets/surya_jaya.jpg',
                  ),
                  _buildStoreItem(
                    'TB. Laksana Jaya',
                    'Sukapura',
                    4.3,
                    'TB. Laksana Jaya Bojongsoang',
                    'assets/laksana_jaya.jpg',
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, VoidCallback onTap) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    isHovered
                        ? Colors.purple.shade300
                        : Colors.purple.shade100,
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Icon(
                    icon,
                    color: isHovered ? Colors.white : Colors.purple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: isHovered ? Colors.purple : Colors.black,
                    fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreItem(String name, String location, double rating, String mapsQuery, String imagePath) {
    return GestureDetector(
      onTap: () => _launchMaps(mapsQuery),
      child: Container(
        width: 150,
        height: 185,
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
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
      ),
    );
  }


  void _launchMaps(String query) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Tidak bisa membuka Google Maps untuk: $query';
    }
  }
}