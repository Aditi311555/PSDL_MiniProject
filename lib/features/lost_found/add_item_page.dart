import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  AddItemPage({required this.currentUser});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedType = 'Lost'; // Default to Lost
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _submitItem() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || description.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('lost_found').add({
        'type': _selectedType, // 'Lost' or 'Found'
        'title': title,
        'description': description,
        'location': location,
        'status': 'Open',
        'reportedBy': widget.currentUser['uceno'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Item reported successfully!")));
      Navigator.pop(context);
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
        title: Text("Report Lost/Found Item"),
        backgroundColor: Color(0xFF3a317c),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle for Lost / Found
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text("I Lost Something"),
                  selected: _selectedType == 'Lost',
                  selectedColor: Colors.red.shade100,
                  onSelected: (selected) =>
                      setState(() => _selectedType = 'Lost'),
                ),
                SizedBox(width: 15),
                ChoiceChip(
                  label: Text("I Found Something"),
                  selected: _selectedType == 'Found',
                  selectedColor: Colors.green.shade100,
                  onSelected: (selected) =>
                      setState(() => _selectedType = 'Found'),
                ),
              ],
            ),
            SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Where was it lost/found?",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description (Color, brand, identifying marks)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3a317c),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit",
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
