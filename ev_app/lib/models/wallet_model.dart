import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String userId;
  final double balance;
  final DateTime lastUpdated;

  WalletModel({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WalletModel(
      userId: documentId,
      balance: (map['balance'] ?? 0.0).toDouble(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': balance,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
