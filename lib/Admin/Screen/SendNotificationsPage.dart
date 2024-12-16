import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendNotificationsPage extends StatefulWidget {
  @override
  _SendNotificationsPageState createState() => _SendNotificationsPageState();
}

class _SendNotificationsPageState extends State<SendNotificationsPage> {
  final TextEditingController _notificationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedUserId = "all"; // Default to sending to all users
  List<Map<String, dynamic>> _users = [];

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
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? 'No email',
            'uid': doc.id, // Use document ID as UID
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
      } else {
        // Send notification to a specific user
        await _firestore.collection('Notifications').add({
          'content': notificationContent,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': _selectedUserId,
        });
      }

      // Show success dialog
      _showSuccessDialog('Notification sent successfully!');
    } catch (e) {
      _showErrorDialog('Error sending notification: $e');
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _notificationController.clear(); // Clear text field
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedUserId,
              items: [
                const DropdownMenuItem<String>(
                  value: "all",
                  child: Text('All Users'),
                ),
                ..._users.map<DropdownMenuItem<String>>((user) {
                  return DropdownMenuItem<String>(
                    value: user['uid'], // UID from Firestore
                    child: Text('${user['name']} (${user['email']})'),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value ?? "all";
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select User',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notificationController,
              decoration: const InputDecoration(
                labelText: 'Enter Notification Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
