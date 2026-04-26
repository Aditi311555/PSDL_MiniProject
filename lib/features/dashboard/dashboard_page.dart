import 'package:flutter/material.dart';

// Corrected imports matching your exact file names and structure
import '../auth/login.dart';
import '../issues/issues_page.dart';
import '../lost_found/lost_found_page.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  DashboardPage({required this.currentUser});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Passing current user data to the sub-pages
    _pages = [
      IssuesPage(currentUser: widget.currentUser),
      LostFoundPage(currentUser: widget.currentUser),
    ];
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Logout"),
          content: Text("Are you sure you want to sign out?"),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Logout", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();

                // Navigating back to LoginPage
                // Note: Ensure the class inside login.dart is named LoginPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CampusCare", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF3a317c),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Color(0xFF3a317c),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "CampusFix",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "LostLink",
          ),
        ],
      ),
    );
  }
}