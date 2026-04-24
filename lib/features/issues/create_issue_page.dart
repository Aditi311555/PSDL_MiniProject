import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateIssuePage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  CreateIssuePage({required this.currentUser});

  @override
  _CreateIssuePageState createState() => _CreateIssuePageState();
}

class _CreateIssuePageState extends State<CreateIssuePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Electricity',
    'Plumbing',
    'WiFi',
    'Furniture',
    'Other',
  ];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _submitIssue() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        location.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('issues').add({
        'title': title,
        'description': description,
        'category': _selectedCategory,
        'location': location,
        'status': 'Pending',
        'upvotes': 0,
        'upvotedBy': [],
        'reportedBy': widget.currentUser['uceno'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Issue reported successfully!")));
      Navigator.pop(context); // Go back to the dashboard
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report an Issue"),
        backgroundColor: Color(0xFF3a317c),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Issue Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Location (e.g., Room 302, Main Bldg)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3a317c),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit Issue",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
