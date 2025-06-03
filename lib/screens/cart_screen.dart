import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color cardBackground = const Color(0xFFF7F1FB);
  final Color iconColor = const Color(0xFF6A4BBC);
  final Color subtitleColor = const Color(0xFF9E9E9E);
  final supabase = Supabase.instance.client;
  List<dynamic> cartItems = [];
  late GoogleMapController _controller;
  late Marker _tukangMarker;
  late Circle _tukangCircle;
  LatLng _initialPosition = const LatLng(
    -6.200000,
    106.816666,
  ); // Default position

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
    fetchPesanan();
  }

  String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void fetchPesanan() async {
    try {
      final response = await supabase
          .from('pesanan')
          .select()
          .eq('proses', 'diproses');
      setState(() {
        cartItems = response;
      });
    } catch (e, stackTrace) {
      print(stackTrace);
    }
  }

  // Initialize Realtime Listener using .stream()
  Future<void> _initializeRealtime() async {
    // Subscribe to changes in the 'lokasi_tukang' table
    final subscription = _supabaseClient
        .from('lokasi_tukang')
        .stream(
          primaryKey: ['id'],
        ) // Or use the unique primary key of the table
        .listen((List<Map<String, dynamic>> data) {
          // Handle the new data here
          if (data.isNotEmpty) {
            final newData =
                data[0]; // Assuming there's one tukang record per row
            final tukangName = newData['tukang_name'];
            final latitude = newData['latitude'];
            final longitude = newData['longitude'];

            setState(() {
              _tukangMarker = Marker(
                markerId: const MarkerId('tukang'),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: tukangName),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
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

  Future<void> updateTukangLocation(
    String tukangName,
    double latitude,
    double longitude,
  ) async {
    final response =
        await _supabaseClient
            .from('lokasi_tukang') // Your Supabase table
            .upsert({
              'tukang_name': tukangName,
              'latitude': latitude,
              'longitude': longitude,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq(
              'tukang_name',
              tukangName,
            ) // Ensure it updates the right tukang by name
            .select()
            .single();

    print(
      'Full Response: $response',
    ); // Print the entire response to see the structure
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
                    final id = item["id"]; // penting untuk update
                    return _buildCartItem(
                      title: item["kategori"] ?? "---",
                      subtitle: item["deskripsi"] ?? "",
                      price: formatRupiah(item["total_harga"]),
                      currentStatus: item["proses"] ?? "diproses",
                      onStatusChanged: (newStatus) async {
                        try {
                          await supabase
                              .from('pesanan')
                              .update({'proses': newStatus})
                              .eq('id', id);

                          setState(() {
                            cartItems[index]["proses"] = newStatus;
                            fetchPesanan();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Status diubah menjadi $newStatus'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          print('Gagal update status: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal mengubah status'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
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
    required String currentStatus,
    required void Function(String) onStatusChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Icon
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(
                title == "---" ? Icons.person : Icons.handyman,
                size: 30,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),

            // Text & Dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        subtitle,
                        style: TextStyle(color: subtitleColor, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          currentStatus == 'selesai'
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentStatus == 'selesai'
                              ? Icons.check_circle_outline
                              : Icons.hourglass_bottom,
                          size: 16,
                          color:
                              currentStatus == 'selesai'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        DropdownButton<String>(
                          value: currentStatus,
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                          borderRadius: BorderRadius.circular(10),
                          items: const [
                            DropdownMenuItem(
                              value: 'diproses',
                              child: Text('Diproses'),
                            ),
                            DropdownMenuItem(
                              value: 'selesai',
                              child: Text('Selesai'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null && value != currentStatus) {
                              onStatusChanged(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Harga saja di pojok kanan atas
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
