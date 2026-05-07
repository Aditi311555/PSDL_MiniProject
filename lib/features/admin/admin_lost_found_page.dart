import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLostFoundPage extends StatelessWidget {
  final Map<String, dynamic> adminData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminLostFoundPage({super.key, required this.adminData});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'Under Review':
        return Colors.orange;
      case 'Closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String itemId,
    Map<String, dynamic> item,
  ) {
    String selectedStatus = item['status'] ?? 'Open';
    final remarkController = TextEditingController(
      text: item['adminRemark'] ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit_note, color: Color(0xFF3a317c)),
              SizedBox(width: 8),
              Text(
                "Update Item",
                style: TextStyle(color: Color(0xFF3a317c), fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${item['type']}: ${item['title']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 15),

                Text(
                  "Update Status:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF3a317c).withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: ['Open', 'Under Review', 'Closed']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: _getStatusColor(s),
                                ),
                                SizedBox(width: 10),
                                Text(s),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedStatus = val);
                      }
                    },
                  ),
                ),
                SizedBox(height: 15),

                Text(
                  "Admin Note:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: remarkController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "e.g. Item is with security office, Room 101",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3a317c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await _firestore.collection('lost_found').doc(itemId).update({
                  'status': selectedStatus,
                  'adminRemark': remarkController.text.trim(),
                  'updatedBy': adminData['name'],
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Item updated!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                SizedBox(height: 10),
                Text(
                  "No items reported yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;
            final itemId = items[index].id;
            final isLost = item['type'] == 'Lost';
            final imageUrls = item['imageUrls'] as List<dynamic>? ?? [];
            final hasRemark = (item['adminRemark'] ?? '').toString().isNotEmpty;

            return Card(
              elevation: 3,
              margin: EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type + Status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLost
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isLost ? Colors.red : Colors.green,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isLost
                                    ? Icons.search_off
                                    : Icons.check_circle_outline,
                                size: 14,
                                color: isLost ? Colors.red : Colors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                isLost ? "LOST" : "FOUND",
                                style: TextStyle(
                                  color: isLost ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              item['status'] ?? '',
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(item['status'] ?? ''),
                            ),
                          ),
                          child: Text(
                            item['status'] ?? '',
                            style: TextStyle(
                              color: _getStatusColor(item['status'] ?? ''),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    Text(
                      item['title'] ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      item['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    // Images strip
                    if (imageUrls.isNotEmpty) ...[
                      SizedBox(height: 10),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          separatorBuilder: (_, _) => SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrls[i],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['location'] ?? '',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Reported by: ${item['reportedBy'] ?? 'Unknown'}",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),

                    // Admin note box
                    if (hasRemark) ...[
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Your note: ${item['adminRemark']}",
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          Icons.edit,
                          size: 16,
                          color: Color(0xFF3a317c),
                        ),
                        label: Text(
                          "Update Status & Note",
                          style: TextStyle(color: Color(0xFF3a317c)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF3a317c)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _showUpdateDialog(context, itemId, item),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
