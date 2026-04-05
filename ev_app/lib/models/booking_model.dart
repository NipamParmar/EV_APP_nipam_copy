import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String stationId;
  final DateTime slotTime;
  final double amount;
  final String paymentStatus; // e.g., 'pending', 'completed', 'failed'
  final String bookingStatus; // e.g., 'active', 'cancelled', 'completed'
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.stationId,
    required this.slotTime,
    required this.amount,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookingModel(
      id: documentId,
      userId: map['userId'] ?? '',
      stationId: map['stationId'] ?? '',
      slotTime: (map['slotTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingStatus: map['bookingStatus'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'stationId': stationId,
      'slotTime': Timestamp.fromDate(slotTime),
      'amount': amount,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
