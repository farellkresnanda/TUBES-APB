import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  late Position _currentPosition;

  // Koordinat toko-toko (lat, long)
  final List<LatLng> storeLocations = [
    LatLng(-6.9121, 107.6346), // Toko 1
    LatLng(-6.9147, 107.6318), // Toko 2
    LatLng(-6.9183, 107.6354), // Toko 3
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
  }

  // Mendapatkan lokasi pengguna
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek status layanan lokasi
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Toko Terdekat'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // Marker untuk lokasi pengguna
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                    // Marker untuk toko
                    ...storeLocations.map((storeLocation) => Marker(
                          width: 80.0,
                          height: 80.0,
                          point: storeLocation,
                          child: const Icon(
                            Icons.store,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        )),
                  ],
                ),
              ],
            ),
    );
  }
}
