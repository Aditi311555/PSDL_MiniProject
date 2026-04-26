import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'create_issue_page.dart';

class IssuesPage extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  IssuesPage({required this.currentUser});

  Future<void> toggleUpvote(
      String issueId,
      List<dynamic> currentUpvoters,
      ) async {
    final userUceno = currentUser['uceno'];
    final docRef = _firestore.collection('issues').doc(issueId);

    if (currentUpvoters.contains(userUceno)) {
      await docRef.update({
        'upvotes': FieldValue.increment(-1),
        'upvotedBy': FieldValue.arrayRemove([userUceno]),
      });
    } else {
      await docRef.update({
        'upvotes': FieldValue.increment(1),
        'upvotedBy': FieldValue.arrayUnion([userUceno]),
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('issues')
            .orderBy('upvotes', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error loading issues"));
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final issues = snapshot.data!.docs;
          if (issues.isEmpty)
            return Center(child: Text("No issues reported yet."));

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index].data() as Map<String, dynamic>;
              final issueId = issues[index].id;
              final upvoters = issue['upvotedBy'] as List<dynamic>? ?? [];
              final hasUpvoted = upvoters.contains(currentUser['uceno']);
              final imageUrls = issue['imageUrls'] as List<dynamic>? ?? [];

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              issue['category'],
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(0xFF3a317c),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(issue['status'])
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              issue['status'],
                              style: TextStyle(
                                color: _getStatusColor(issue['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Text(
                        issue['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        issue['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ── Photo strip ─────────────────────────────────
                      if (imageUrls.isNotEmpty) ...[
                        SizedBox(height: 12),
                        _PhotoStrip(
                          imageUrls: imageUrls.cast<String>(),
                        ),
                      ],

                      SizedBox(height: 15),
                      Divider(),

                      // ── Footer row ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                issue['location'],
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  hasUpvoted
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  color: hasUpvoted
                                      ? Color(0xFF3a317c)
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    toggleUpvote(issueId, upvoters),
                              ),
                              Text(
                                "${issue['upvotes']} Votes",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
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
            builder: (_) => CreateIssuePage(currentUser: currentUser),
          ),
        ),
        icon: Icon(Icons.add),
        label: Text("Report Issue"),
      ),
    );
  }
}

// ─── Reusable horizontal photo strip ────────────────────────────────────────

class _PhotoStrip extends StatelessWidget {
  final List<String> imageUrls;

  const _PhotoStrip({required this.imageUrls});

  void _openFullscreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenGallery(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openFullscreen(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrls[index],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Full-screen image gallery ───────────────────────────────────────────────

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