import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
      "subtitle": "Pak Darsono - Spesialis pompa air",
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

  late GoogleMapController _controller;
  late Marker _tukangMarker;
  late Circle _tukangCircle;
  LatLng _initialPosition = const LatLng(-6.200000, 106.816666); // Default position

  late SupabaseClient _supabaseClient;

  @override
  void initState() {
    super.initState();
    _supabaseClient = Supabase.instance.client;
    _tukangMarker = Marker(
      markerId: const MarkerId('tukang'),
      position: _initialPosition,
      infoWindow: const InfoWindow(title: 'Tukang'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    _tukangCircle = Circle(
      circleId: const CircleId('tukangCircle'),
      center: _initialPosition,
      radius: 100.0, // 100 meters radius
      fillColor: Colors.green.withOpacity(0.3),
      strokeWidth: 1,
    );
    _initializeRealtime();
  }

  // Initialize Realtime Listener using .stream()
  Future<void> _initializeRealtime() async {
  // Subscribe to changes in the 'lokasi_tukang' table
  final subscription = _supabaseClient
      .from('lokasi_tukang')
      .stream(primaryKey: ['id']) // Or use the unique primary key of the table
      .listen((List<Map<String, dynamic>> data) {
        // Handle the new data here
        if (data.isNotEmpty) {
          final newData = data[0]; // Assuming there's one tukang record per row
          final tukangName = newData['tukang_name'];
          final latitude = newData['latitude'];
          final longitude = newData['longitude'];

          setState(() {
            _tukangMarker = Marker(
              markerId: const MarkerId('tukang'),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: tukangName),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            );
            _tukangCircle = Circle(
              circleId: const CircleId('tukangCircle'),
              center: LatLng(latitude, longitude),
              radius: 100.0, // 100 meters radius
              fillColor: Colors.green.withOpacity(0.3),
              strokeWidth: 1,
            );
          });
        }
      });

  // Make sure to subscribe to the data stream
  await subscription;
}

Future<void> updateTukangLocation(String tukangName, double latitude, double longitude) async {
  final response = await _supabaseClient
      .from('lokasi_tukang') // Your Supabase table
      .upsert({
        'tukang_name': tukangName,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('tukang_name', tukangName) // Ensure it updates the right tukang by name
      .select()
      .single();

  print('Full Response: $response'); // Print the entire response to see the structure
}

  // Get current location (for demonstration purposes)
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });

    // Update tukang's location to Supabase
    updateTukangLocation('Tukang XYZ', position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Pesanan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: cartItems.isEmpty
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
                    onDismissed: (_) {
                      _removeItem(index);
                    },
                    child: _buildCartItem(
                      title: item["title"] ?? "---",
                      subtitle: item["subtitle"] ?? "",
                      price: item["price"] ?? "",
                      onDelete: () {
                        _removeItem(index);
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentLocation(); // Get and update tukang's location
        },
        child: const Icon(Icons.location_on),
        tooltip: "Update Tukang Location",
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
}