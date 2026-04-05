import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminPurchaseHistory extends StatelessWidget {
  const AdminPurchaseHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: CustomScrollView(
        slivers: [
          // --- MODERN STICKY APP BAR ---
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Transactions',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20),
              ),
              background: Container(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),

          // --- TRANSACTIONS LIST ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF28C76F))),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text("No records found", style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      DateTime date = (data['timestamp'] as Timestamp).toDate();
                      String formattedDate = DateFormat('dd MMM, hh:mm a').format(date);

                      return _buildTransactionCard(data, formattedDate)
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> data, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // Future: Details screen dikha sakte ho yahan se
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Holder
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28C76F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Color(0xFF28C76F), size: 28),
                ),
                const SizedBox(width: 16),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['userName'] ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.black26),
                          const SizedBox(width: 4),
                          Text(date, style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount & Energy
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${data['amount']}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${data['energykWh'] ?? '0'} kWh",
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}