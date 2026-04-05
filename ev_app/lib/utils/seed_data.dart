import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station_model.dart';
import 'package:flutter/foundation.dart';

Future<void> seedDummyStations(double baseLat, double baseLng) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Check if stations already exist to avoid duplicates
  final snapshot = await firestore.collection('stations').limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    if (kDebugMode) {
      print('Stations already exist. Skipping seed.');
    }
    return;
  }

  List<StationModel> dummyStations = [
    StationModel(
      id: '', // Firestore will auto-generate document IDs
      name: 'SuperCharge Central',
      lat: baseLat + 0.005,
      lng: baseLng + 0.005,
      availableSlots: 4,
      pricePerHour: 15.0,
      chargerType: 'Fast DC (CCS2)',
    ),
    StationModel(
      id: '',
      name: 'Green Energy Hub',
      lat: baseLat - 0.003,
      lng: baseLng - 0.008,
      availableSlots: 2,
      pricePerHour: 12.5,
      chargerType: 'AC Type 2',
    ),
    StationModel(
      id: '',
      name: 'City Mall Ev Point',
      lat: baseLat + 0.008,
      lng: baseLng - 0.002,
      availableSlots: 0, // Testing empty slots
      pricePerHour: 14.0,
      chargerType: 'Fast DC (CHAdeMO)',
    ),
  ];

  for (var station in dummyStations) {
    await firestore.collection('stations').add(station.toMap());
  }
  
  if (kDebugMode) {
    print('Successfully inserted dummy stations into Firestore.');
  }
}
