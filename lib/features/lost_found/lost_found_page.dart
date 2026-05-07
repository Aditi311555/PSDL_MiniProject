import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_item_page.dart';

class LostFoundPage extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LostFoundPage({required this.currentUser});

  static const Color primaryColor = Color(0xFF3a317c);
  static const Color backgroundColor = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black87,
        title: Text(
          "Lost & Found",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('lost_found')
            .orderBy('timestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error loading items"));

          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          if (items.isEmpty)
            return Center(
              child: Text(
                "No items reported yet.",
                style: TextStyle(color: Colors.grey),
              ),
            );

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item =
              items[index].data() as Map<String, dynamic>;
              final isLost = item['type'] == 'Lost';
              final imageUrls =
                  item['imageUrls'] as List<dynamic>? ?? [];

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ─── IMAGE ─────────────────────────────
                    imageUrls.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrls[0],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isLost
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isLost
                            ? Icons.search_off
                            : Icons.check_circle_outline,
                        color:
                        isLost ? Colors.red : Colors.green,
                      ),
                    ),

                    SizedBox(width: 14),

                    // ─── CONTENT ───────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          // TYPE + STATUS
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLost
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isLost ? "LOST" : "FOUND",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isLost
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),

                              Spacer(),

                              Text(
                                item['status'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          Text(
                            item['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            item['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                            TextStyle(color: Colors.grey[700]),
                          ),

                          SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['location'] ?? '',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
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
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AddItemPage(currentUser: currentUser),
          ),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Report Item",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}