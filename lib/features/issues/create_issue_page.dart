import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

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

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isUploadingImages = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Color primaryColor = const Color(0xFF5B4BDB);
  final Color secondaryColor = const Color(0xFF7C6CF2);
  final Color backgroundColor = const Color(0xFFF5F7FB);

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

    final limited = picked
        .take(remaining)
        .map((x) => File(x.path))
        .toList();

    setState(() {
      _selectedImages.addAll(limited);
    });

    if (picked.length > remaining) {
      _showSnack(
        "Only $remaining more photo(s) could be added (max 3).",
      );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      labelStyle: TextStyle(
        color: Colors.grey.shade700,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Attach Photos",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(width: 6),

            Text(
              "(optional, max 3)",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),

            const Spacer(),

            if (_selectedImages.length < 3)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickImages,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        color: primaryColor,
                        size: 18,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "Add",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 110,

            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,

              separatorBuilder: (_, __) =>
              const SizedBox(width: 12),

              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(18),

                        child: Image.file(
                          _selectedImages[index],
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 6,
                      right: 6,

                      child: GestureDetector(
                        onTap: () => _removeImage(index),

                        child: Container(
                          padding: const EdgeInsets.all(4),

                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 30,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Tap to upload photos",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Help admins understand the issue better",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
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
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,

        title: const Text(
          "Report Issue",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(26),

                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),

                    child: const Icon(
                      Icons.report_problem_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: const [
                        Text(
                          "CampusFix",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Report issues quickly and help improve campus facilities.",
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // FORM CARD
            Container(
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: _inputStyle(
                      "Issue Title",
                      Icons.title_rounded,
                    ),
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    decoration: _inputStyle(
                      "Category",
                      Icons.dashboard_customize_rounded,
                    ),

                    value: _selectedCategory,

                    borderRadius: BorderRadius.circular(16),

                    items: _categories
                        .map(
                          (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                        .toList(),

                    onChanged: (val) =>
                        setState(() => _selectedCategory = val),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _locationController,
                    decoration: _inputStyle(
                      "Location",
                      Icons.location_on_outlined,
                    ).copyWith(
                      hintText:
                      "e.g. Room 302, Main Building",
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,

                    decoration: _inputStyle(
                      "Description",
                      Icons.description_outlined,
                    ).copyWith(
                      alignLabelWithHint: true,
                      hintText:
                      "Describe the issue clearly...",
                    ),
                  ),

                  const SizedBox(height: 26),

                  _buildImagePicker(),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      onPressed:
                      _isLoading ? null : _submitIssue,

                      style: ElevatedButton.styleFrom(
                        elevation: 0,

                        backgroundColor: primaryColor,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                      ),

                      child: _isLoading
                          ? Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,

                            child:
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Text(
                            _isUploadingImages
                                ? "Uploading photos..."
                                : "Submitting...",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        "Submit Issue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}