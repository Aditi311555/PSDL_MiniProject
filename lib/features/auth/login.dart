import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import 'signup_page.dart';
import '../admin/admin_login_page.dart'; // ✅ ADDED

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String hashPassword(String password) {
    const salt = "cummins_secret_salt";
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  Future<void> _login() async {
    print("DEBUG: _login() called");
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      showSnack("Please enter your credentials");
      return;
    }

    setState(() => _isLoading = true);

    try {
      QuerySnapshot result;

      if (identifier.contains('@')) {
        result = await _firestore
            .collection('users')
            .where('email', isEqualTo: identifier.toLowerCase())
            .get();
      } else {
        result = await _firestore
            .collection('users')
            .where('uceno', isEqualTo: identifier)
            .get();
      }

      if (result.docs.isEmpty) {
        showSnack("Account not found. Please Sign Up.");
        setState(() => _isLoading = false);
        return;
      }

      final userData = result.docs.first.data() as Map<String, dynamic>;
      final storedHash = userData['passwordHash'];

      if (storedHash == hashPassword(password)) {
        showSnack("Welcome back, ${userData['name']}!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(currentUser: userData),
          ),
        );
      } else {
        showSnack("Incorrect password");
      }
    } catch (e) {
      showSnack("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void showSnack(String msg) {
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
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://commons.wikimedia.org/wiki/Category:Cummins_College_of_Engineering_for_Women',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Icon(Icons.school_outlined, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Campus Connect",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 30),

                  Card(
                    color: Colors.white.withOpacity(0.85),
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        children: [
                          Text(
                            "Student Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3a317c),
                            ),
                          ),
                          SizedBox(height: 25),

                          TextField(
                            controller: _identifierController,
                            decoration: _inputStyle(
                              "UCENO or College Email",
                              Icons.person,
                            ),
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
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
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
                                      "LOGIN",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? "),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SignupPage(),
                                  ),
                                ),
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xFF3a317c),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ✅ ADDED ADMIN LOGIN SECTION
                          SizedBox(height: 15),
                          Divider(color: Colors.grey.shade300),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminLoginPage(),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Login as Admin",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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