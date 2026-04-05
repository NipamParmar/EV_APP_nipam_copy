import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return _showError("Please enter all details");
    }
    setState(() => _isLoading = true);
    try {
      await _authService.login(_emailController.text.trim(), _passwordController.text.trim());
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
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
            Container(
              height: MediaQuery.of(context).size.height * 0.25, // Size reduced to 25%
              width: double.infinity,
              margin: const EdgeInsets.only(top: 60, bottom: 10),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/register.png'), //
                  fit: BoxFit.contain, // Fits the whole car properly
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt, size: 45, color: Color(0xFF28C76F)).animate().scale(),
                  const SizedBox(height: 10),
                  const Text('Welcome Back', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black)),
                  const Text('Access your EV Dashboard', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  
                  const SizedBox(height: 30),
                  
                  _buildTextField("Email Address", _emailController, Icons.email_outlined, false),
                  const SizedBox(height: 15),
                  _buildTextField("Password", _passwordController, Icons.lock_outline, true),
                  
                  const SizedBox(height: 25),
                  
                  _buildPrimaryButton("Login Now", _login),

                  const SizedBox(height: 25),
                  const Center(child: Text("OR", style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 25),

                  _buildSocialButton("Continue with Google", Icons.g_mobiledata_rounded, _loginWithGoogle),

                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                      child: RichText(
                        text: const TextSpan(
                          text: "New to EV-Charge? ",
                          style: TextStyle(color: Colors.black45),
                          children: [
                            TextSpan(text: "Register", style: TextStyle(color: Color(0xFF28C76F), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isPass) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF28C76F)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback press) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : press,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF28C76F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 1,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildSocialButton(String text, IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}