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

  final Color primaryColor = const Color(0xFF5B4BDB);
  final Color secondaryColor = const Color(0xFF7C6CF2);
  final Color backgroundColor = const Color(0xFFF5F7FB);

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      hintText: label,

      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),

      filled: true,
      fillColor: backgroundColor,

      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 20,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Stack(
        children: [
          // TOP GRADIENT
          Container(
            height: MediaQuery.of(context).size.height * 0.42,

            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  secondaryColor,
                ],
              ),

              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),

                child: Column(
                  children: [
                    // ICON
                    Container(
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,

                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),

                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Join Campus Connect and get started",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 34),

                    // SIGNUP CARD
                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(28),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Student Registration",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Fill your details to create your account",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // UCENO
                            TextField(
                              controller: _ucenoController,

                              decoration: _inputStyle(
                                "UCENO",
                                Icons.badge_outlined,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // NAME
                            TextField(
                              controller: _nameController,

                              decoration: _inputStyle(
                                "Full Name",
                                Icons.person_outline_rounded,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // YEAR + BRANCH
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedYear,

                                    decoration: _inputStyle(
                                      "Year",
                                      Icons.calendar_today_outlined,
                                    ),

                                    dropdownColor: Colors.white,

                                    borderRadius:
                                    BorderRadius.circular(16),

                                    items: _years
                                        .map(
                                          (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text(y),
                                      ),
                                    )
                                        .toList(),

                                    onChanged: (val) {
                                      setState(() {
                                        _selectedYear = val;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedBranch,

                                    decoration: _inputStyle(
                                      "Branch",
                                      Icons.account_tree_outlined,
                                    ),

                                    dropdownColor: Colors.white,

                                    borderRadius:
                                    BorderRadius.circular(16),

                                    items: _branches
                                        .map(
                                          (b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b),
                                      ),
                                    )
                                        .toList(),

                                    onChanged: (val) {
                                      setState(() {
                                        _selectedBranch = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // EMAIL
                            TextField(
                              controller: _emailController,
                              keyboardType:
                              TextInputType.emailAddress,

                              decoration: _inputStyle(
                                "College Email",
                                Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // PASSWORD
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,

                              decoration: _inputStyle(
                                "Password",
                                Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  splashRadius: 20,

                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,

                                    color: Colors.grey.shade500,
                                  ),

                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // SIGNUP BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 58,

                              child: ElevatedButton(
                                onPressed:
                                _isLoading ? null : signup,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(18),
                                  ),
                                ),

                                child: _isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : const Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // LOGIN LINK
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () => Navigator.pop(context),

                                  child: Padding(
                                    padding:
                                    const EdgeInsets.only(left: 5),

                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}