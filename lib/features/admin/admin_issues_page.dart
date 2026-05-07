import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminIssuesPage extends StatelessWidget {
  final Map<String, dynamic> adminData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminIssuesPage({super.key, required this.adminData});

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

  void _showUpdateDialog(
    BuildContext context,
    String issueId,
    Map<String, dynamic> issue,
  ) {
    String selectedStatus = issue['status'] ?? 'Pending';
    final remarkController = TextEditingController(
      text: issue['adminRemark'] ?? '',
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
                "Update Issue",
                style: TextStyle(color: Color(0xFF3a317c), fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show issue title as reference
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issue['title'] ?? '',
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
                    items: ['Pending', 'In Progress', 'Resolved']
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
                  "Work Update / Remark:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: remarkController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        "e.g. Electrician dispatched, will fix by tomorrow",
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
                await _firestore.collection('issues').doc(issueId).update({
                  'status': selectedStatus,
                  'adminRemark': remarkController.text.trim(),
                  'updatedBy': adminData['name'],
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Issue updated!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text("Save Update", style: TextStyle(color: Colors.white)),
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
          .collection('issues')
          .orderBy('upvotes', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error loading issues"));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final issues = snapshot.data!.docs;
        if (issues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                SizedBox(height: 10),
                Text(
                  "No issues reported yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: issues.length,
          itemBuilder: (context, index) {
            final issue = issues[index].data() as Map<String, dynamic>;
            final issueId = issues[index].id;
            final imageUrls = issue['imageUrls'] as List<dynamic>? ?? [];
            final hasRemark = (issue['adminRemark'] ?? '')
                .toString()
                .isNotEmpty;

            return Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            issue['category'] ?? '',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Color(0xFF3a317c),
                          padding: EdgeInsets.symmetric(horizontal: 4),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              issue['status'] ?? '',
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(issue['status'] ?? ''),
                            ),
                          ),
                          child: Text(
                            issue['status'] ?? '',
                            style: TextStyle(
                              color: _getStatusColor(issue['status'] ?? ''),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Text(
                      issue['title'] ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      issue['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    // Show images if any
                    if (imageUrls.isNotEmpty) ...[
                      SizedBox(height: 10),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          separatorBuilder: (_, _) => SizedBox(width: 8),
                          itemBuilder: (context, i) => ClipRRect(
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

                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 5),

                    // Location + upvotes
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            issue['location'] ?? '',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        Icon(
                          Icons.thumb_up,
                          size: 14,
                          color: Color(0xFF3a317c),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${issue['upvotes'] ?? 0} votes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                          "Reported by: ${issue['reportedBy'] ?? 'Unknown'}",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),

                    // Admin remark box (shows if remark exists)
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
                                "Your remark: ${issue['adminRemark']}",
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
                          "Update Status & Remark",
                          style: TextStyle(color: Color(0xFF3a317c)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF3a317c)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _showUpdateDialog(context, issueId, issue),
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
