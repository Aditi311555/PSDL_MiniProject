import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLostFoundPage extends StatelessWidget {
  final Map<String, dynamic> adminData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminLostFoundPage({required this.adminData});

  final Color primaryColor = const Color(0xFF5B4BDB);
  final Color backgroundColor = const Color(0xFFF5F7FB);

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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.all(24),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                "Update Item",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ITEM PREVIEW
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "${item['type']}: ${item['title']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "Update Status",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(16),
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
                            const SizedBox(width: 10),
                            Text(
                              s,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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

                const SizedBox(height: 22),

                const Text(
                  "Admin Note",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: remarkController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                    "e.g. Item is with security office, Room 101",

                    filled: true,
                    fillColor: backgroundColor,

                    contentPadding: const EdgeInsets.all(16),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
                    content: const Text("Item updated successfully"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              },

              child: const Text(
                "Save Update",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          return const Center(
            child: Text("Error loading items"),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data!.docs;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 70,
                  color: Colors.grey.shade300,
                ),

                const SizedBox(height: 14),

                Text(
                  "No items reported yet",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          itemCount: items.length,

          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;

            final itemId = items[index].id;

            final isLost = item['type'] == 'Lost';

            final imageUrls = item['imageUrls'] as List<dynamic>? ?? [];

            final hasRemark = (item['adminRemark'] ?? '')
                .toString()
                .isNotEmpty;

            return Container(
              margin: const EdgeInsets.only(bottom: 18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BADGES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: isLost
                                ? Colors.red.withOpacity(0.08)
                                : Colors.green.withOpacity(0.08),

                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                isLost
                                    ? Icons.search_off_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 15,
                                color:
                                isLost ? Colors.red : Colors.green,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                isLost ? "LOST" : "FOUND",
                                style: TextStyle(
                                  color:
                                  isLost ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              item['status'] ?? '',
                            ).withOpacity(0.12),

                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: Text(
                            item['status'] ?? '',

                            style: TextStyle(
                              color: _getStatusColor(
                                item['status'] ?? '',
                              ),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // TITLE
                    Text(
                      item['title'] ?? '',

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // DESCRIPTION
                    Text(
                      item['description'] ?? '',

                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    // IMAGES
                    if (imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 90,

                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,

                          itemCount: imageUrls.length,

                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),

                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(18),

                            child: Image.network(
                              imageUrls[i],
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // INFO BOX
                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  item['location'] ?? '',

                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  "Reported by ${item['reportedBy'] ?? 'Unknown'}",

                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ADMIN NOTE
                    if (hasRemark) ...[
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: Colors.blue.shade100,
                          ),
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.admin_panel_settings_rounded,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                item['adminRemark'],

                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Colors.white,
                        ),

                        label: const Text(
                          "Update Status & Note",

                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
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