import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveUserPage extends StatefulWidget {
  @override
  _RemoveUserListState createState() => _RemoveUserListState();
}

class _RemoveUserListState extends State<RemoveUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  bool _isAdmin = false; // Flag to track if the user is an admin

  @override
  void initState() {
    super.initState();
    _checkAdminStatus(); // Verify if the logged-in user is an admin
    _fetchUsers();
  }

  /// Check if the current user is an admin
  Future<void> _checkAdminStatus() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showErrorDialog('You are not logged in.');
        return;
      }

      // Check if the logged-in user's email exists in the admin collection
      DocumentSnapshot adminSnapshot =
          await _firestore.collection('admin').doc(currentUser.email).get();

      setState(() {
        _isAdmin =
            adminSnapshot.exists; // Set the admin flag based on existence
      });

      if (!_isAdmin) {
        _showErrorDialog('You do not have admin privileges.');
      }
    } catch (e) {
      print('Error checking admin status: $e');
      _showErrorDialog('Error checking admin status: $e');
    }
  }

  /// Fetch users from Firestore
  Future<void> _fetchUsers() async {
    if (!_isAdmin) return; // Only fetch users if the current user is an admin

    try {
      QuerySnapshot snapshot = await _firestore.collection('Users').get();
      setState(() {
        _users = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'uid': doc.id, // Use the document ID as UID
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
      _showErrorDialog('Error fetching users: $e');
    }
  }

  /// Remove user from Firestore and optionally Firebase Authentication
  Future<void> _removeUser(String uid) async {
    if (!_isAdmin) {
      _showErrorDialog('You do not have admin privileges to remove users.');
      return;
    }

    try {
      // Remove user from Firestore
      await _firestore.collection('Users').doc(uid).delete();

      // Refresh user list
      _fetchUsers();
      _showSuccessDialog('User removed successfully!');
    } catch (e) {
      print('Error removing user: $e');
      _showErrorDialog('Error removing user: $e');
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
    if (!_isAdmin) {
      return Center(
          child: Text('You do not have permission to access this page.'));
    }

    return _users.isEmpty
        ? Center(child: Text('No users to remove'))
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(_users[index]['name'] ?? ''),
                  subtitle: Text(_users[index]['email'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeUser(_users[index]['uid']),
                  ),
                ),
              );
            },
          );
  }
}
