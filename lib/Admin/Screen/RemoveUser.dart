import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveUserPage extends StatefulWidget {
  @override
  _RemoveUserPageState createState() => _RemoveUserPageState();
}

class _RemoveUserPageState extends State<RemoveUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// Fetch users from Firestore
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore.collection('Users').get();
      setState(() {
        _users = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'uid': doc.id, // Document ID as UID
          };
        }).toList();
      });
    } catch (e) {
      _showErrorDialog('Error fetching users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Remove user from Firestore (without deleting from Firebase Authentication)
  Future<void> _removeUser(String uid) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Remove user from Firestore
      await _firestore.collection('Users').doc(uid).delete();

      _fetchUsers(); // Refresh user list
      _showSuccessDialog('User removed successfully!');
    } catch (e) {
      _showErrorDialog('Error removing user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Remove Users')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Remove Users')),
      body: _users.isEmpty
          ? Center(child: Text('No users to remove.'))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(user['name'] ?? 'No Name'),
                    subtitle: Text(user['email'] ?? 'No Email'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeUser(user['uid']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
