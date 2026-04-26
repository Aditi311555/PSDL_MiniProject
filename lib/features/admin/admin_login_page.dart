import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // MUST use same salt as student login
  String hashPassword(String password) {
    const salt = "cummins_secret_salt";
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  Future<void> _adminLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please enter credentials");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isEmpty) {
        _showSnack("Admin account not found");
        setState(() => _isLoading = false);
        return;
      }

      final adminData = result.docs.first.data();
      final storedHash = adminData['passwordHash'];

      if (storedHash == hashPassword(password)) {
        _showSnack("Welcome, ${adminData['name']}!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardPage(adminData: adminData),
          ),
        );
      } else {
        _showSnack("Incorrect password");
      }
    } catch (e) {
      _showSnack("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF3a317c)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark purple gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3a317c), Color(0xFF1a1a2e)],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  // Admin icon
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Admin Portal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "CampusConnect Management",
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  SizedBox(height: 40),

                  // Login card
                  Card(
                    color: Colors.white.withOpacity(0.95),
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        children: [
                          Text(
                            "Administrator Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3a317c),
                            ),
                          ),
                          SizedBox(height: 25),

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputStyle("Admin Email", Icons.email),
                          ),
                          SizedBox(height: 15),

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputStyle("Password", Icons.lock)
                                .copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                          ),
                          SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _adminLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3a317c),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "LOGIN AS ADMIN",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white70),
                    label: Text(
                      "Back to Student Login",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
