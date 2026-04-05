import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final double walletBalance;
  final DateTime createdAt;
  final String role; // Added: 'user' or 'admin'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.walletBalance,
    required this.createdAt,
    this.role = 'user', // Default to 'user'
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: map['role'] ?? 'user', // Parse role from Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'walletBalance': walletBalance,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role, // Include role in map
    };
  }
}