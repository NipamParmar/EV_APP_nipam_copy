import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station_model.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class StationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of all stations
  Stream<List<StationModel>> getAllStations() {
    return _firestore.collection('stations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return StationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get nearby stations based on radius (Haversine formula for simple distance check)
  // Note: For large scale production apps, use GeoFlutterFire or similar.
  Future<List<StationModel>> getNearbyStations(double lat, double lng, {double radiusInKm = 5.0}) async {
    QuerySnapshot snapshot = await _firestore.collection('stations').get();
    
    List<StationModel> nearbyStations = [];
    
    for (var doc in snapshot.docs) {
      StationModel station = StationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      double distance = _calculateDistance(lat, lng, station.lat, station.lng);
      
      if (distance <= radiusInKm) {
        nearbyStations.add(station);
      }
    }
    
    return nearbyStations;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.pi / 180
    double a = 0.5 - cos((lat2 - lat1) * p) / 2 + 
               cos(lat1 * p) * cos(lat2 * p) * 
               (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Get specific station details
  Future<StationModel?> getStationById(String stationId) async {
    DocumentSnapshot doc = await _firestore.collection('stations').doc(stationId).get();
    if (doc.exists) {
      return StationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
