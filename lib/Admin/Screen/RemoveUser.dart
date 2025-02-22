import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveUserPage extends StatefulWidget {
  @override
  _RemoveUserPageState createState() => _RemoveUserPageState();
}

class _RemoveUserPageState extends State<RemoveUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Users')
          .where('status', isEqualTo: 'approved') // Only fetch approved users
          .get();
      setState(() {
        _users = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'uid': doc.id,
            'aadhaarUrl': data['aadhaarUrl'] ?? '',
            'city': data['city'] ?? '',
            'mobile': data['mobile'] ?? '',
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

  Future<void> _removeUser(String uid) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('Users').doc(uid).update({
        'status': 'Removed',
      });
      _fetchUsers(); // Refresh user list
      _showSuccessDialog('User marked as removed successfully!');
    } catch (e) {
      _showErrorDialog('Error updating user status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                    onTap: () {
                      // Navigate to user details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(user: user),
                        ),
                      );
                    },
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

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailsPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (user['aadhaarUrl'] != null && user['aadhaarUrl'].isNotEmpty)
              Column(
                children: [
                  Text(
                    'Aadhaar Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.network(
                    user['aadhaarUrl'],
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 100, color: Colors.red),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Text(
              'User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text('Name: ${user['name'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Email: ${user['email'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('Mobile: ${user['mobile'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            Text('City: ${user['city'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
