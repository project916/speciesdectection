import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 201, 167, 105),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notification =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(notification['content'] ?? 'No content'),
                subtitle: Text(
                  notification['timestamp'] != null
                      ? (notification['timestamp'] as Timestamp)
                          .toDate()
                          .toString()
                      : 'Unknown time',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
