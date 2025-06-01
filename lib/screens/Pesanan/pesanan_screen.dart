import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tubes_1/screens/Pesanan/pesanan_form.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class pesananScreen extends StatefulWidget {
  final String kategori;

  const pesananScreen({super.key, required this.kategori});

  @override
  State<pesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<pesananScreen> {
  final TextEditingController alamatController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool lokasiDipilih = false;
  String displayLokasi = 'Mencari lokasi perangkat...';
  double? latitude;
  double? longitude;
  bool _isPressed = false;

  List<String> alamatList = [];

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAlamatUser();
      _getLocationFromDevice();
    });
  }

  void fetchAlamatUser() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        print('User belum login');
        return;
      }

      final userId = user.id;

      final List<Map<String, dynamic>> response = await supabase
          .from('alamat_tersimpan')
          .select();

      setState(() {
        alamatList.clear();
        if (response.isEmpty) {
          print('Tidak ada alamat tersimpan untuk user: $userId');
          return;
        }
        for (var row in response) {
          final alamatLengkap = row['alamat'] as String?;
          if (alamatLengkap != null && alamatLengkap.isNotEmpty) {
            alamatList.add(alamatLengkap);
          }
        }
      });
      print('Alamat berhasil diambil untuk user $userId: $alamatList');
    } catch (e, stackTrace) {
      print('Terjadi kesalahan saat fetch alamat: $e');
      print('Stack trace: $stackTrace');
    }
  }


  Future<void> _getLocationFromDevice() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            displayLokasi = 'Permission lokasi ditolak';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          displayLokasi = 'Permission lokasi ditolak permanen';
        });
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        lokasiDipilih = true;
      });

      await _updateAddressFromCoordinates(latitude!, longitude!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (latitude != null && longitude != null) {
          mapController.move(LatLng(latitude!, longitude!), 16.0);
        }
      });
    } catch (e) {
      setState(() {
        displayLokasi = 'Gagal mendapatkan lokasi perangkat: $e';
      });
    }
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lon) async {
    try {
      print('Mencoba mendapatkan alamat dari koordinat: $lat, $lon');
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String alamatBaru = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          displayLokasi = alamatBaru;
        });
      } else {
        setState(() {
          displayLokasi = 'Alamat tidak ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        displayLokasi = 'Gagal mendapatkan alamat: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String kategori = widget.kategori;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.yellow],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Kategori $kategori',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[900],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilih lokasi untuk kategori $kategori yang dibutuhkan',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Bagian utama isi konten
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Map
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (latitude != null && longitude != null)
                            ? FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: LatLng(latitude!, longitude!),
                                  initialZoom: 16,
                                  interactionOptions:
                                      const InteractionOptions(flags: InteractiveFlag.all),
                                  onTap: (tapPosition, point) async {
                                    setState(() {
                                      latitude = point.latitude;
                                      longitude = point.longitude;
                                      lokasiDipilih = true;
                                    });
                                    await _updateAddressFromCoordinates(latitude!, longitude!);
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                    userAgentPackageName: 'com.example.yourappname',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 60.0,
                                        height: 60.0,
                                        point: LatLng(latitude!, longitude!),
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text('Menunggu lokasi...'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lokasi tujuan pesanan tukang.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.bookmark, color: Colors.black54, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Alamat tersimpan",
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: alamatList.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada alamat tersimpan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        :SingleChildScrollView(
                          child: Column(
                            children: alamatList.map((alamat) {
                              final isSelected = alamat == displayLokasi;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      displayLokasi = alamat;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? const Color.fromARGB(255, 240, 240, 240)
                                        : Colors.transparent,
                                    foregroundColor:
                                        isSelected ? Colors.grey[600] : Colors.black,
                                    elevation: 0,
                                    side: const BorderSide(color: Colors.grey),
                                    alignment: Alignment.centerLeft,
                                    minimumSize: const Size.fromHeight(60),
                                    padding: const EdgeInsets.all(8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(alamat),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Tombol lokasi saat ini (tampilkan alamat perangkat sekarang)
                    ElevatedButton(
                      onPressed: lokasiDipilih
                          ? () {
                              setState(() {
                                _isPressed = !_isPressed;// toggle status
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.grey.shade300 ,
                        foregroundColor:Colors.grey[600],
                        elevation: 0,
                        side: const BorderSide(color: Colors.grey),
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size.fromHeight(60),
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(displayLokasi),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormPesan(
                              displayLokasi: displayLokasi,
                              kategori: kategori,
                            ),
                          ),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Lanjutkan Pesan Tukang',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
