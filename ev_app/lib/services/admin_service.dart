import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of total revenue from all bookings
  Stream<double> getTotalRevenue() {
    return _db.collection('bookings').snapshots().map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0.0).toDouble();
      }
      return total;
    });
  }

  // Stream of total energy consumed (assuming 1 hour = 7kWh for example)
  Stream<double> getTotalEnergyUsed() {
    return _db.collection('bookings').snapshots().map((snapshot) {
      double totalEnergy = 0.0;
      for (var doc in snapshot.docs) {
        // Calculation: If you store duration, multiply by a constant rate
        // Or if you store 'energykWh' in the booking model
        totalEnergy += (doc.data()['energykWh'] ?? 5.5).toDouble(); 
      }
      return totalEnergy;
    });
  }
}