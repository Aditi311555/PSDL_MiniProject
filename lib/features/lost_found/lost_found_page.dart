import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_item_page.dart';

class LostFoundPage extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LostFoundPage({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return Center(child: Text("No items reported yet."));

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;
              final isLost = item['type'] == 'Lost';

              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isLost
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    child: Icon(
                      isLost ? Icons.search_off : Icons.check_circle_outline,
                      color: isLost ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        item['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Location: ${item['location']}",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        "Status: ${item['status']}",
                        style: TextStyle(
                          color: Color(0xFF3a317c),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
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
