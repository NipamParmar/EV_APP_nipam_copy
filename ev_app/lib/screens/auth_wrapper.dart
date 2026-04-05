import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_screen.dart';
import 'login_screen.dart';
import 'admin/admin_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF28C76F))));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) return const Scaffold(body: SizedBox());

              if (userSnap.hasData && userSnap.data!.exists) {
                final data = userSnap.data!.data() as Map<String, dynamic>;
                // Admin check from Firestore
                if (data['role'] == 'admin') return const AdminDashboard();
              }
              return const MainScreen();
            },
          );
        }
        return const LoginScreen();
      },
    );
  }
}