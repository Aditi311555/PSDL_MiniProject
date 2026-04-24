import 'package:flutter/material.dart';

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
    // Initialize pages, passing the current user down
    _pages = [
      IssuesPage(currentUser: widget.currentUser),
      LostFoundPage(currentUser: widget.currentUser),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CampusCare"),
        backgroundColor: Color(0xFF3a317c),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              '/login',
            ), // Assuming you set up routes
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "LostLink"),
        ],
      ),
    );
  }
}
