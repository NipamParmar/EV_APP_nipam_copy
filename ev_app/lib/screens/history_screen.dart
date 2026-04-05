import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login to see bookings", style: TextStyle(color: Colors.black87)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Booking History', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingService.getUserBookings(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF28C76F)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "You have no bookings yet.",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(bookings[index]).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY();
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    bool isActive = booking.bookingStatus == 'active';
    Color statusColor = isActive ? const Color(0xFF28C76F) : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Station: ${booking.stationId.substring(0, 8)}...', // Ideally fetch Station name via service
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.bookingStatus.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_filled, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(booking.slotTime),
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Text(
                '\$${booking.amount.toStringAsFixed(2)} • ${booking.paymentStatus}',
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}