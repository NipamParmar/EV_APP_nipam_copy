import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import '../services/auth_service.dart';
import '../screens/upi_payment_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Professional Color Palette
  static const Color kPrimaryGreen = Color(0xFF00A36C); // Emerald Green
  static const Color kBackground = Color(0xFFF8FAFC);  // Soft Slate Blue-Grey
  static const Color kTextDark = Color(0xFF0F172A);    // Navy Dark

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Please login"));

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// DYNAMIC USER & WALLET DATA
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator(color: kPrimaryGreen);
                      
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      double balance = (data['walletBalance'] ?? 0.0).toDouble(); //
                      String name = data['name'] ?? "User";
                      String email = data['email'] ?? "";

                      return Column(
                        children: [
                          _buildProfileHeader(name, email),
                          const SizedBox(height: 24),
                          _buildPremiumWalletCard(context, balance),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
                    },
                  ),

                  const SizedBox(height: 35),
                  _buildSectionLabel("ACCOUNT SETTINGS"),
                  _buildActionTile(Icons.history_rounded, 'Booking History', 'Manage your charging slots'),
                  _buildActionTile(Icons.account_balance_wallet_outlined, 'Transactions', 'Review your wallet activity'),
                  _buildActionTile(Icons.notifications_active_outlined, 'Notifications', 'App alerts & updates'),
                  _buildActionTile(Icons.security_outlined, 'Security', 'Password & Privacy'),

                  const SizedBox(height: 35),
                  _buildLogoutButton(authService),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      backgroundColor: kBackground,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: const Text("My Account", 
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimaryGreen.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: kPrimaryGreen.withOpacity(0.1),
              child: Text(name[0].toUpperCase(), 
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kTextDark)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWalletCard(BuildContext context, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryGreen, Color(0xFF008060)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: kPrimaryGreen.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WALLET BALANCE', 
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withOpacity(0.3), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text("₹${balance.toStringAsFixed(2)}", 
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showTopUpDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kPrimaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text('RECHARGE WALLET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: kPrimaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: kPrimaryGreen, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kTextDark)),
        subtitle: Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black12),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
    );
  }

  Widget _buildLogoutButton(AuthService auth) {
    return InkWell(
      onTap: () => auth.logout(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.08)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 10),
            Text("Sign Out", 
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text("Recharge", style: TextStyle(fontWeight: FontWeight.w900, color: kTextDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("How much would you like to add?", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kPrimaryGreen),
              decoration: InputDecoration(
                hintText: "₹ 0.00",
                filled: true,
                fillColor: kBackground,
                contentPadding: const EdgeInsets.all(20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              double amount = double.tryParse(controller.text) ?? 0;
              if (amount <= 0) return;
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => UpiPaymentSheet(
                  amount: amount,
                  bookingId: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: FirebaseAuth.instance.currentUser!.uid, //
                  receiverUpiId: "nirmaljoshi123456789@okaxis",
                  receiverName: "EV Wallet TopUp",
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}