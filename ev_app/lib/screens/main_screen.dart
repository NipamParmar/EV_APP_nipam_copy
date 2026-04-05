import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'history_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'bookings_screen.dart'; //
import 'vehicle_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  static const Color bgColor = Color(0xFFF9F9F9);
  static const Color accentGreen = Color(0xFF28C76F); 

  // --- UPDATED SCREENS LIST ---
  final List<Widget> _screens = const [
    VehicleScreen(key: PageStorageKey('vehicle')),
    YourBookingsScreen(key: PageStorageKey('bookings')), //
    MapScreen(key: PageStorageKey('map')),
    HistoryScreen(key: PageStorageKey('history')),
    ProfileScreen(key: PageStorageKey('profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: PageStorage(
        bucket: _bucket,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_filled, Icons.home_outlined, "Home"),
              _buildNavItem(1, Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, "Bookings"), //
             _buildNavItem(2, Icons.ev_station_rounded, Icons.ev_station_outlined, "Station"),
              _buildNavItem(3, Icons.insert_chart_rounded, Icons.insert_chart_outlined, "Activity"),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? accentGreen.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? accentGreen : Colors.grey.shade400,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? const Color(0xFF1A1D1E) : Colors.grey.shade400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}