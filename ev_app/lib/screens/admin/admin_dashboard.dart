import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'admin_home_content.dart';       // <--- YE IMPORT ZAROORI HAI
import 'admin_purchase_history.dart';
import 'admin_settings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeContent(), // <--- Ab ye error nahi dega
    const AdminPurchaseHistory(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      bottomNavigationBar: _buildBottomNavbar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, "Home", 0),
          _navItem(Icons.history_rounded, "History", 1),
          _navItem(Icons.settings_rounded, "Settings", 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF28C76F).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF28C76F) : Colors.black45, size: 26),
            if (isSelected) 
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(label, style: const TextStyle(color: Color(0xFF28C76F), fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}