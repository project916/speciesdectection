import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendNotificationsPage extends StatefulWidget {
  @override
  _SendNotificationsPageState createState() => _SendNotificationsPageState();
}

class _SendNotificationsPageState extends State<SendNotificationsPage> {
  final TextEditingController _notificationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedUserId = "all"; // Default to sending to all users
  List<Map<String, dynamic>> _users = [];
  final String serverKey =
      'YOUR_FCM_SERVER_KEY'; // Replace with your Firebase Cloud Messaging server key

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// Fetch users from Firestore
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Users').get();
      setState(() {
        _users = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'uid': doc.id, // Ensure this is a string
          };
        }).toList();
      });
    } catch (e) {
      _showErrorDialog('Error fetching users: $e');
    }
  }

  /// Send notification to users
  Future<void> _sendNotification() async {
    final notificationContent = _notificationController.text.trim();
    if (notificationContent.isEmpty) {
      _showErrorDialog('Please enter notification content');
      return;
    }

    try {
      if (_selectedUserId == "all") {
        // Send notification to all users
        await _firestore.collection('Notifications').add({
          'content': notificationContent,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': null, // Null indicates notification for all users
        });

        // Optionally, fetch all user tokens and send FCM messages
        QuerySnapshot snapshot = await _firestore.collection('Users').get();
        for (var doc in snapshot.docs) {
          String? fcmToken = doc['fcmToken'];
          if (fcmToken != null) {
            await _sendPushNotification(fcmToken, notificationContent);
          }
        }
      } else {
        // Send notification to a specific user
        await _firestore.collection('Notifications').add({
          'content': notificationContent,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': _selectedUserId,
        });

        // Retrieve FCM token and send a push notification
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(_selectedUserId).get();
        String? fcmToken = userDoc['fcmToken'];
        if (fcmToken != null) {
          await _sendPushNotification(fcmToken, notificationContent);
        }
      }

      // Show success dialog
      _showSuccessDialog('Notification sent successfully!');
    } catch (e) {
      _showErrorDialog('Error sending notification: $e');
    }
  }

  /// Send push notification using FCM
  Future<void> _sendPushNotification(String fcmToken, String content) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': 'Admin Notification',
            'body': content,
          },
        }),
      );

      if (response.statusCode != 200) {
        print('Error sending push notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM push notification: $e');
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _notificationController.clear(); // Clear text field
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedUserId,
              items: [
                DropdownMenuItem<String>(
                  value: "all",
                  child: Text('All Users'),
                ),
                ..._users.map<DropdownMenuItem<String>>((user) {
                  return DropdownMenuItem<String>(
                    value: user['uid'], // Ensure this is of type String
                    child: Text('${user['name']} (${user['email']})'),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value ?? "all";
                });
              },
              decoration: InputDecoration(
                labelText: 'Select User',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notificationController,
              decoration: InputDecoration(
                labelText: 'Enter Notification Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
