import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

class AddItemPage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const AddItemPage({super.key, required this.currentUser});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedType = 'Lost';
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

  Future<void> _pickImages() async {
    final remaining = 3 - _selectedImages.length;
    if (remaining <= 0) {
      _showSnack("You can attach a maximum of 3 photos.");
      return;
    }

    final picked = await _picker.pickMultiImage(imageQuality: 75);
    if (picked.isEmpty) return;

    final limited = picked.take(remaining).map((x) => File(x.path)).toList();
    setState(() => _selectedImages.addAll(limited));

    if (picked.length > remaining) {
      _showSnack("Only $remaining more photo(s) could be added (max 3).");
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submitItem() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || description.isEmpty || location.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload images to Cloudinary
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        setState(() => _isUploadingImages = true);

        for (final image in _selectedImages) {
          final url = await CloudinaryService.uploadImage(image);
          if (url != null) imageUrls.add(url);
        }

        setState(() => _isUploadingImages = false);
      }

      // 2. Save to Firestore with image URLs
      await _firestore.collection('lost_found').add({
        'type': _selectedType,
        'title': title,
        'description': description,
        'location': location,
        'status': 'Open',
        'imageUrls': imageUrls,
        'reportedBy': widget.currentUser['uceno'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSnack("Item reported successfully!");
      Navigator.pop(context);
    } catch (e) {
      _showSnack("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TypeChip(
          label: "I Lost Something",
          icon: Icons.search_off,
          selected: _selectedType == 'Lost',
          selectedColor: Colors.red.shade100,
          selectedIconColor: Colors.red,
          onSelected: () => setState(() => _selectedType = 'Lost'),
        ),
        SizedBox(width: 15),
        _TypeChip(
          label: "I Found Something",
          icon: Icons.check_circle_outline,
          selected: _selectedType == 'Found',
          selectedColor: Colors.green.shade100,
          selectedIconColor: Colors.green,
          onSelected: () => setState(() => _selectedType = 'Found'),
        ),
      ],
    );
  }

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
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32),
                  SizedBox(height: 6),
                  Text(
                    "Tap to add photos",
                    style: TextStyle(color: Colors.grey),
                  ),
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
        title: Text("Report Lost/Found Item"),
        backgroundColor: Color(0xFF3a317c),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeToggle(),
            SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Where was it lost/found?",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description (color, brand, identifying marks)",
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
                onPressed: _isLoading ? null : _submitItem,
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

/// Small helper widget to keep the toggle clean.
class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final Color selectedIconColor;
  final VoidCallback onSelected;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.selectedIconColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? selectedIconColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? selectedIconColor : Colors.grey),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? selectedIconColor : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}