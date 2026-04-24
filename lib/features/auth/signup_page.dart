import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _ucenoController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedYear;
  String? _selectedBranch;

  final List<String> _years = ['FE', 'SE', 'TE', 'BE'];
  final List<String> _branches = ['Comp', 'IT', 'E&TC', 'Mech', 'Instru'];

  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _ucenoController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String hashPassword(String password) {
    const salt = "cummins_secret_salt";
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  Future<void> signup() async {
    final uceno = _ucenoController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (uceno.isEmpty ||
        name.isEmpty ||
        _selectedYear == null ||
        _selectedBranch == null ||
        email.isEmpty ||
        password.isEmpty) {
      showSnack("Please fill all fields");
      return;
    }

    if (!email.endsWith('@cumminscollege.in')) {
      showSnack("Use college email only");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doc = await _firestore.collection('users').doc(uceno).get();
      if (doc.exists) {
        showSnack("User already exists");
        setState(() => _isLoading = false);
        return;
      }

      await _firestore.collection('users').doc(uceno).set({
        'uceno': uceno,
        'name': name,
        'year': _selectedYear,
        'branch': _selectedBranch,
        'email': email,
        'passwordHash': hashPassword(password),
        'createdAt': FieldValue.serverTimestamp(),
      });

      showSnack("Signup successful!");
      Navigator.pop(context);
    } catch (e) {
      showSnack("Error: $e");
    }
    setState(() => _isLoading = false);
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Modern Input Decoration
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
          // Background Image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                // Swap with your local asset: AssetImage('assets/cummins_bg.jpg')
                image: NetworkImage(
                  'https://commons.wikimedia.org/wiki/Category:Cummins_College_of_Engineering_for_Women',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(color: Colors.black.withOpacity(0.5)),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
              child: Column(
                children: [
                  // Logo or Title
                  Icon(Icons.school, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Cummins College Pune",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Signup Card
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
                            "Create Account",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3a317c),
                            ),
                          ),
                          SizedBox(height: 25),

                          TextField(
                            controller: _ucenoController,
                            decoration: _inputStyle("UCENO", Icons.badge),
                          ),
                          SizedBox(height: 15),
                          TextField(
                            controller: _nameController,
                            decoration: _inputStyle("Full Name", Icons.person),
                          ),
                          SizedBox(height: 15),

                          // Row for Dropdowns
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: _inputStyle(
                                    "Year",
                                    Icons.calendar_today,
                                  ),
                                  value: _selectedYear,
                                  items: _years
                                      .map(
                                        (y) => DropdownMenuItem(
                                          value: y,
                                          child: Text(y),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedYear = val),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: _inputStyle(
                                    "Branch",
                                    Icons.account_tree,
                                  ),
                                  value: _selectedBranch,
                                  items: _branches
                                      .map(
                                        (b) => DropdownMenuItem(
                                          value: b,
                                          child: Text(b),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedBranch = val),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),

                          TextField(
                            controller: _emailController,
                            decoration: _inputStyle(
                              "College Email",
                              Icons.email,
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
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                          ),
                          SizedBox(height: 30),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : signup,
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
                                      "SIGN UP",
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Already have an account? Login",
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
