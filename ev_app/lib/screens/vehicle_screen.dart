import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

// --- IMPORT YOUR MAP PAGE HERE ---
import 'map_screen.dart'; 

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  static const Color kPrimaryGreen = Color(0xFF00D261);
  static const Color kBackground = Color(0xFFF9FBFA);
  static const Color kCardWhite = Colors.white;
  static const Color kTextDark = Color(0xFF1A1D1E);

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: StreamBuilder<DocumentSnapshot>(
        // Real-time user data listen kar rahe hain
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          String userName = "User";
          double walletBalance = 0.0;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['name'] ?? "User";
            walletBalance = (data['walletBalance'] ?? 0.0).toDouble();
          }

          return Stack(
            children: [
              _buildAmbientGlows(),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(userName),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildVehicleHero(),
                          const SizedBox(height: 30),
                          _buildMainStatsCard(walletBalance),
                          const SizedBox(height: 40),
                          
                          _buildSectionHeader('EV Services'),
                          _buildServiceGrid(context), // Context pass kiya redirection ke liye
                          
                          const SizedBox(height: 160), 
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildFloatingStatusDock(),
            ],
          );
        },
      ),
    );
  }

  // --- NAVIGATION LOGIC ---
  Widget _buildServiceGrid(BuildContext context) {
    return Row(
      children: [
        _serviceCard(
          "Find Station", 
          Icons.map_rounded, 
          const Color(0xFF28C76F),
          () {
            HapticFeedback.mediumImpact();
            // --- REDIRECT TO MAP PAGE ---
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const MapScreen())
            );
          }
        ),
        const SizedBox(width: 16),
        _serviceCard(
          "Book Slot", 
          Icons.calendar_today_rounded, 
          Colors.orange,
          () {
            HapticFeedback.lightImpact();
            // Future: Yahan BookingScreen ka logic dal sakte ho
          }
        ),
      ],
    );
  }

  Widget _serviceCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            color: kCardWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  // --- UI COMPONENTS (STATIC/VISUAL) ---

  Widget _buildAmbientGlows() {
    return Positioned(
      top: -150,
      right: -100,
      child: CircleAvatar(
        radius: 200,
        backgroundColor: kPrimaryGreen.withOpacity(0.08),
      ).animate().fadeIn(duration: 2.seconds),
    );
  }

  Widget _buildAppBar(String name) {
    return SliverAppBar(
      backgroundColor: kBackground.withOpacity(0.5),
      elevation: 0,
      pinned: true,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello, ${name.split(' ')[0]} 👋', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark.withOpacity(0.5))),
          const Text('MY EV STATUS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kTextDark)),
        ],
      ),
    );
  }

  Widget _buildVehicleHero() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(2, (index) => Container(
          width: 240 + (index * 40.0),
          height: 240 + (index * 40.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kPrimaryGreen.withOpacity(0.1 - (index * 0.05)), width: 2),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: Offset(1.1 + (index * 0.1), 1.1 + (index * 0.1)),
          duration: (2 + index).seconds,
          curve: Curves.easeInOut,
        )),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("75%", 
              style: TextStyle(fontSize: 82, fontWeight: FontWeight.w900, color: kTextDark, letterSpacing: -4, height: 1.0)),
            const SizedBox(height: 4),
            Text("CHARGED", 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 4, color: kPrimaryGreen.withOpacity(0.8))),
          ],
        ),
      ],
    );
  }

  Widget _buildMainStatsCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('75%', 'Battery', Icons.bolt_rounded, kPrimaryGreen),
          _buildVerticalDivider(),
          _buildStatItem('₹${balance.toStringAsFixed(0)}', 'Wallet', Icons.account_balance_wallet_rounded, Colors.blueAccent),
          _buildVerticalDivider(),
          _buildStatItem('21°C', 'Ambient', Icons.thermostat_rounded, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildFloatingStatusDock() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: kTextDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Row(
                children: [
                  Icon(Icons.electric_bolt_rounded, color: kPrimaryGreen, size: 30),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Supercharging Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Remaining: 24 mins', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('75%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kTextDark)),
        Text(label, style: TextStyle(color: kTextDark.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title.toUpperCase(), 
        style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
    );
  }

  Widget _buildVerticalDivider() => Container(height: 30, width: 1, color: Colors.black.withOpacity(0.05));
}