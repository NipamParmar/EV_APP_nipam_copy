import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PROFILE HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF28C76F).withOpacity(0.1),
                    child: const Icon(Icons.admin_panel_settings, size: 50, color: Color(0xFF28C76F)),
                  ).animate().scale(duration: 500.ms),
                  const SizedBox(height: 15),
                  const Text(
                    "Nirmal Joshi", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    user?.email ?? "admin@evcharge.com",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildRoleBadge(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- ACCOUNT OPTIONS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account Settings", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 15),
                  
                  _settingsTile(Icons.person_outline, "Personal Info", "Manage name and email"),
                  _settingsTile(Icons.security_outlined, "Security", "Change password"),
                  
                  const SizedBox(height: 30),
                  const Text("System", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 15),

                  // --- LOGOUT BUTTON ---
                  _buildLogoutButton(),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF28C76F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text("SUPER ADMIN", 
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _settingsTile(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0F172A)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        subtitle: Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => FirebaseAuth.instance.signOut(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 15),
            Text("Logout Session", 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.red),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}