import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String upiTransactionId;
  final String status; // 'success', 'failure', 'pending'
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.upiTransactionId,
    required this.status,
    required this.timestamp,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      upiTransactionId: map['upiTransactionId'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'upiTransactionId': upiTransactionId,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
