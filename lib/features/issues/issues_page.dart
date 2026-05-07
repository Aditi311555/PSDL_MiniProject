import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'create_issue_page.dart';

class IssuesPage extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  IssuesPage({required this.currentUser});

  final Color primaryColor = const Color(0xFF5B4BDB);
  final Color secondaryColor = const Color(0xFF7C6CF2);
  final Color backgroundColor = const Color(0xFFF5F7FB);

  Future<void> toggleUpvote(
      String issueId,
      List<dynamic> currentUpvoters,
      ) async {
    final userUceno = currentUser['uceno'];

    final docRef =
    _firestore.collection('issues').doc(issueId);

    if (currentUpvoters.contains(userUceno)) {
      await docRef.update({
        'upvotes': FieldValue.increment(-1),
        'upvotedBy':
        FieldValue.arrayRemove([userUceno]),
      });
    } else {
      await docRef.update({
        'upvotes': FieldValue.increment(1),
        'upvotedBy':
        FieldValue.arrayUnion([userUceno]),
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.redAccent;

      case 'In Progress':
        return Colors.orange;

      case 'Resolved':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red.shade50;

      case 'In Progress':
        return Colors.orange.shade50;

      case 'Resolved':
        return Colors.green.shade50;

      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('issues')
            .orderBy('upvotes', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading issues",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          final issues = snapshot.data!.docs;

          if (issues.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color:
                        primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.report_problem_outlined,
                        size: 60,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "No issues reported yet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Tap the button below to report the first issue on campus.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              100,
            ),

            itemCount: issues.length,

            itemBuilder: (context, index) {
              final issue =
              issues[index].data()
              as Map<String, dynamic>;

              final issueId = issues[index].id;

              final upvoters =
                  issue['upvotedBy']
                  as List<dynamic>? ??
                      [];

              final hasUpvoted = upvoters.contains(
                currentUser['uceno'],
              );

              final imageUrls =
                  issue['imageUrls']
                  as List<dynamic>? ??
                      [];

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 18,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                        children: [
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: primaryColor
                                  .withOpacity(0.08),

                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  Icons.category_rounded,
                                  size: 16,
                                  color: primaryColor,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  issue['category'],
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight:
                                    FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: _getStatusBg(
                                issue['status'],
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                            ),

                            child: Text(
                              issue['status'],

                              style: TextStyle(
                                color: _getStatusColor(
                                  issue['status'],
                                ),

                                fontWeight:
                                FontWeight.w700,

                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // TITLE
                      Text(
                        issue['title'],

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // DESCRIPTION
                      Text(
                        issue['description'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),

                      // PHOTOS
                      if (imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 18),

                        _PhotoStrip(
                          imageUrls:
                          imageUrls.cast<String>(),
                        ),
                      ],

                      const SizedBox(height: 18),

                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                      ),

                      const SizedBox(height: 12),

                      // FOOTER
                      Row(
                        children: [
                          // LOCATION
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.all(
                                    8,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors
                                        .grey.shade100,

                                    borderRadius:
                                    BorderRadius
                                        .circular(12),
                                  ),

                                  child: Icon(
                                    Icons
                                        .location_on_rounded,
                                    size: 16,
                                    color:
                                    Colors.grey.shade700,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    issue['location'],

                                    overflow:
                                    TextOverflow
                                        .ellipsis,

                                    style: TextStyle(
                                      color: Colors
                                          .grey.shade700,

                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // UPVOTE
                          GestureDetector(
                            onTap: () => toggleUpvote(
                              issueId,
                              upvoters,
                            ),

                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 250,
                              ),

                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),

                              decoration: BoxDecoration(
                                color: hasUpvoted
                                    ? primaryColor
                                    .withOpacity(0.1)
                                    : Colors.grey.shade100,

                                borderRadius:
                                BorderRadius.circular(
                                  16,
                                ),
                              ),

                              child: Row(
                                children: [
                                  Icon(
                                    hasUpvoted
                                        ? Icons.thumb_up
                                        : Icons
                                        .thumb_up_alt_outlined,

                                    color: hasUpvoted
                                        ? primaryColor
                                        : Colors
                                        .grey.shade600,

                                    size: 18,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "${issue['upvotes']}",

                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.w700,

                                      color: hasUpvoted
                                          ? primaryColor
                                          : Colors
                                          .grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          gradient: LinearGradient(
            colors: [
              primaryColor,
              secondaryColor,
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: Colors.transparent,

          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateIssuePage(
                currentUser: currentUser,
              ),
            ),
          ),

          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
          ),

          label: const Text(
            "Report Issue",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// PHOTO STRIP

class _PhotoStrip extends StatelessWidget {
  final List<String> imageUrls;

  const _PhotoStrip({
    required this.imageUrls,
  });

  void _openFullscreen(
      BuildContext context,
      int initialIndex,
      ) {
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
      height: 105,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: imageUrls.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 12),

        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openFullscreen(
              context,
              index,
            ),

            child: Hero(
              tag: imageUrls[index],

              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(20),

                  child: Image.network(
                    imageUrls[index],
                    width: 105,
                    height: 105,
                    fit: BoxFit.cover,

                    loadingBuilder:
                        (_, child, progress) =>
                    progress == null
                        ? child
                        : Container(
                      width: 105,
                      height: 105,
                      color: Colors.grey.shade100,

                      child: const Center(
                        child:
                        CircularProgressIndicator(),
                      ),
                    ),

                    errorBuilder:
                        (_, __, ___) => Container(
                      width: 105,
                      height: 105,
                      color: Colors.grey.shade100,

                      child: const Icon(
                        Icons.broken_image_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// FULLSCREEN GALLERY

class _FullscreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullscreenGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGallery> createState() =>
      _FullscreenGalleryState();
}

class _FullscreenGalleryState
    extends State<_FullscreenGallery> {
  late PageController _pageController;

  late int _current;

  @override
  void initState() {
    super.initState();

    _current = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
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
        elevation: 0,
        backgroundColor: Colors.black,

        foregroundColor: Colors.white,

        title: Text(
          "${_current + 1} / ${widget.imageUrls.length}",

          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: PageView.builder(
        controller: _pageController,

        itemCount: widget.imageUrls.length,

        onPageChanged: (i) =>
            setState(() => _current = i),

        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Hero(
                tag: widget.imageUrls[index],

                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.contain,

                  loadingBuilder:
                      (_, child, progress) =>
                  progress == null
                      ? child
                      : const Center(
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}