import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_item_page.dart';

class LostFoundPage extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LostFoundPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('lost_found')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading items"));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;
          if (items.isEmpty) {
            return Center(child: Text("No items reported yet."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;
              final isLost = item['type'] == 'Lost';
              final imageUrls = item['imageUrls'] as List<dynamic>? ?? [];

              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Left: icon or thumbnail ──────────────────
                      imageUrls.isNotEmpty
                          ? GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _FullscreenGallery(
                              imageUrls: imageUrls.cast<String>(),
                              initialIndex: 0,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrls[0],
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: Center(
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorBuilder: (_, _, _) => Container(
                                  width: 72,
                                  height: 72,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            if (imageUrls.length > 1)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "+${imageUrls.length - 1}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                          : CircleAvatar(
                        radius: 28,
                        backgroundColor: isLost
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        child: Icon(
                          isLost
                              ? Icons.search_off
                              : Icons.check_circle_outline,
                          color: isLost ? Colors.red : Colors.green,
                        ),
                      ),

                      SizedBox(width: 14),

                      // ── Right: text content ──────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isLost
                                        ? Colors.red.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isLost
                                          ? Colors.red.shade200
                                          : Colors.green.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    isLost ? "LOST" : "FOUND",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isLost
                                          ? Colors.red
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  item['status'],
                                  style: TextStyle(
                                    color: Color(0xFF3a317c),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),

                            Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),

                            Text(
                              item['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(height: 6),

                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 13, color: Colors.grey),
                                SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    item['location'],
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF3a317c),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddItemPage(currentUser: currentUser),
          ),
        ),
        icon: Icon(Icons.add),
        label: Text("Report Item"),
      ),
    );
  }
}

// ─── Full-screen gallery (same as issues_page) ───────────────────────────────

class _FullscreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullscreenGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("${_current + 1} / ${widget.imageUrls.length}"),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
          );
        },
      ),
    );
  }
}