import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Fixed Typo
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage("Please fill all fields", Colors.orange);
      return;
    }
    if (_passwordController.text.length < 6) {
      _showMessage("Password must be at least 6 characters", Colors.orange);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signup(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      ); //
      _showMessage("Account created successfully!", const Color(0xFF28C76F));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showMessage(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SMALLER IMAGE INTEGRATION ---
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.22, // Even smaller for signup form
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 55, bottom: 10),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/register.png'), //
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SafeArea(child: BackButton(color: Colors.black)),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.electric_bolt_rounded, size: 40, color: Color(0xFF28C76F)).animate().scale(),
                  const SizedBox(height: 10),
                  const Text('Join the Network', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
                  ).animate().fadeIn().slideY(begin: 0.2),
                  const Text('Create an account to start charging your EV.', style: TextStyle(color: Colors.black45, fontSize: 14)),
                  
                  const SizedBox(height: 25),
                  
                  _buildTextField('Full Name', _nameController, Icons.person_outline, false),
                  const SizedBox(height: 15),
                  _buildTextField('Email Address', _emailController, Icons.email_outlined, false),
                  const SizedBox(height: 15),
                  _buildTextField('Password', _passwordController, Icons.lock_outline, true),
                  
                  const SizedBox(height: 30),
                  
                  _buildSignupButton(),
                  
                  const SizedBox(height: 25),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.black45),
                          children: [TextSpan(text: "Login", style: TextStyle(color: Color(0xFF28C76F), fontWeight: FontWeight.bold))],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF28C76F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF28C76F), size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black38, fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }
}