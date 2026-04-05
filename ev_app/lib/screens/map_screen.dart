import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/station_service.dart';
import '../models/station_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final StationService _stationService = StationService();
  Position? _currentPosition;
  bool _isLoading = true;
  StationModel? _selectedStation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isLoading = true);

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar("Bhai, GPS On karo pehle settings se!");
        setState(() => _isLoading = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar("Location permission ke bina stations nahi milenge.");
          setState(() => _isLoading = false);
          return;
        }
      }

      // High Accuracy taaki nearest stations sahi dikhein
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best //
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _mapController.move(LatLng(position.latitude, position.longitude), 14.5);

    } catch (e) {
      debugPrint("Location Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Background Map with Station Stream
          _isLoading && _currentPosition == null
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF28C76F)))
              : _buildMapWithStreams(),

          // Search Bar Overlay
          _buildTopOverlay(),

          // Horizontal Station List Overlay
          _buildBottomStationList(),
        ],
      ),
    );
  }

  Widget _buildMapWithStreams() {
    return StreamBuilder<List<StationModel>>(
      stream: _stationService.getAllStations(), //
      builder: (context, snapshot) {
        List<Marker> markers = [];

        // 1. Blue Pin for YOUR current location
        if (_currentPosition != null) {
          markers.add(
            Marker(
              width: 50.0,
              height: 50.0,
              point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              child: const Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 45),
            ),
          );
        }

        // 2. Green Pins for ALL NEAREST stations in DB
        if (snapshot.hasData) {
          for (var station in snapshot.data!) {
            markers.add(
              Marker(
                width: 60.0,
                height: 60.0,
                point: LatLng(station.lat, station.lng), //
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedStation = station);
                    _mapController.move(LatLng(station.lat, station.lng), 15.5);
                  },
                  child: Icon(
                    Icons.ev_station_rounded, 
                    color: _selectedStation?.id == station.id ? Colors.orange : const Color(0xFF28C76F), 
                    size: 42
                  ).animate().scale(),
                ),
              ),
            );
          }
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition != null
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : const LatLng(21.1702, 72.8311), // Surat default
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.nirmal.ev_app',
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }

  Widget _buildBottomStationList() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 210,
        margin: const EdgeInsets.only(bottom: 25),
        child: StreamBuilder<List<StationModel>>(
          stream: _stationService.getAllStations(), // Real-time fetch
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(); 
            }

            // Sort logic (Optional): Aap distance ke basis pe yahan sort kar sakte ho
            final stations = snapshot.data!;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                return _buildStationCard(stations[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStationCard(StationModel station) {
    bool isSelected = _selectedStation?.id == station.id;
    
    // Distance calculate karke dikhane ke liye (Optional)
    double distance = 0;
    if (_currentPosition != null) {
      distance = Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude, 
        station.lat, station.lng
      ) / 1000; // Meters to KM
    }

    return GestureDetector(
      onTap: () {
        setState(() => _selectedStation = station);
        _mapController.move(LatLng(station.lat, station.lng), 15.5);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: const Color(0xFF28C76F), width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                Text("${distance.toStringAsFixed(1)} km away", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(station.chargerType, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹${station.pricePerHour}/h", style: const TextStyle(color: Color(0xFF28C76F), fontWeight: FontWeight.w900, fontSize: 16)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28C76F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Book Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 12),
              Text('Search nearest EV stations...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}