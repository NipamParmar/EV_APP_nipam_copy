import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("Business Insights", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.insights_rounded, color: Color(0xFF28C76F))
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildTopHighlightCard(),
            const SizedBox(height: 25),
            
            const Text("Growth Overview", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            
            // Two Stats in a Row
            Row(
              children: [
                Expanded(child: _buildMiniStat("Active Hubs", "12", Icons.ev_station, Colors.blue)),
                const SizedBox(width: 15),
                Expanded(child: _buildMiniStat("New Users", "+48", Icons.person_add_alt_1, Colors.purple)),
              ],
            ),
            
            const SizedBox(height: 30),
            _buildRecentActivityHeader(context),
            
            // Live Firestore Stream for Transactions
            _buildLiveTransactionList(),
          ],
        ),
      ),
    );
  }

  // 1. Sexy Gradient Main Card
  Widget _buildTopHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF28C76F), Color(0xFF1D9755)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: const Color(0xFF28C76F).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOTAL REVENUE", 
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text("₹8,42,500.00", 
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(Icons.bolt, "1,240 kWh", "Energy"),
              _infoTile(Icons.trending_up, "+12.5%", "Monthly"),
              _infoTile(Icons.timer, "420 hrs", "Uptime"),
            ],
          )
        ],
      ),
    ).animate().fadeIn().scale(delay: 100.ms, curve: Curves.easeOutBack);
  }

  Widget _infoTile(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  // 2. Small Stats Cards
  Widget _buildMiniStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text(title, style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }

  // 3. Header
  Widget _buildRecentActivityHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Live Transactions", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          TextButton(
            onPressed: () {}, 
            child: const Text("See All", style: TextStyle(color: Color(0xFF28C76F), fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  // 4. Real-time List from Firestore
  Widget _buildLiveTransactionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.bolt_rounded, color: Color(0xFF28C76F)),
                ),
                title: Text(data['userName'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Payment Received", style: TextStyle(fontSize: 12)),
                trailing: Text("₹${data['amount']}", 
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, fontSize: 16)),
              ),
            ).animate().fadeIn(delay: (200 + (index * 100)).ms).slideX();
          },
        );
      },
    );
  }
}