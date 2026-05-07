import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

class CreateIssuePage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const CreateIssuePage({super.key, required this.currentUser});

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

  // Image state
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isUploadingImages = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Opens the gallery and lets the user pick up to 3 images total.
  Future<void> _pickImages() async {
    final remaining = 3 - _selectedImages.length;
    if (remaining <= 0) {
      _showSnack("You can attach a maximum of 3 photos.");
      return;
    }

    final picked = await _picker.pickMultiImage(imageQuality: 75);
    if (picked.isEmpty) return;

    final limited = picked.take(remaining).map((x) => File(x.path)).toList();

    setState(() {
      _selectedImages.addAll(limited);
    });

    if (picked.length > remaining) {
      _showSnack("Only $remaining more photo(s) could be added (max 3).");
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submitIssue() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        location.isEmpty ||
        _selectedCategory == null) {
      _showSnack("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload images to Cloudinary first
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        setState(() => _isUploadingImages = true);

        for (final image in _selectedImages) {
          final url = await CloudinaryService.uploadImage(image);
          if (url != null) {
            imageUrls.add(url);
          }
        }

        setState(() => _isUploadingImages = false);
      }

      // 2. Save issue doc with image URLs to Firestore
      await _firestore.collection('issues').add({
        'title': title,
        'description': description,
        'category': _selectedCategory,
        'location': location,
        'status': 'Pending',
        'upvotes': 0,
        'upvotedBy': [],
        'imageUrls': imageUrls,
        'reportedBy': widget.currentUser['uceno'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSnack("Issue reported successfully!");
      Navigator.pop(context);
    } catch (e) {
      _showSnack("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Photos (optional, max 3)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Spacer(),
            if (_selectedImages.length < 3)
              TextButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.add_photo_alternate, color: Color(0xFF3a317c)),
                label: Text(
                  "Add Photos",
                  style: TextStyle(color: Color(0xFF3a317c)),
                ),
              ),
          ],
        ),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              separatorBuilder: (_, _) => SizedBox(width: 10),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32),
                  SizedBox(height: 6),
                  Text("Tap to add photos", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report an Issue"),
        backgroundColor: Color(0xFF3a317c),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Issue Title",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              initialValue: _selectedCategory,
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
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 20),

            _buildImagePicker(),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3a317c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      _isUploadingImages
                          ? "Uploading photos..."
                          : "Submitting...",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                )
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