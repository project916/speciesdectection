import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  _AdminApprovalPageState createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  // Function to approve user
  Future<void> approveUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'status': 'approved',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User approved successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error approving user: $e")),
      );
    }
  }

  // Function to reject user
  Future<void> rejectUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'status': 'rejected',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User rejected.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error rejecting user: $e")),
      );
    }
  }

  // Navigate to user details screen
  void navigateToUserDetails(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin User Approvals'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              // Pass user data instead of the entire snapshot
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: user['aadhaarUrl'] != null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user['aadhaarUrl']),
                        )
                      : const Icon(Icons.person, size: 40),
                  title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email']),
                  onTap: () => navigateToUserDetails(user.data()), // Pass user data here
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => approveUser(user.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => rejectUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display User's Aadhaar Image
            Center(
              child: user['aadhaarUrl'] != null
                  ? Image.network(
                      user['aadhaarUrl'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 200, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Display user name
            Text(
              "Name: ${user['name']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display user email
            Text("Email: ${user['email']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            // Display user mobile number
            Text("Mobile: ${user['mobile']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            // Display user city
            Text("City: ${user['city']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // User status
            Text(
              "Status: ${user['status']}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: user['status'] == 'approved' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
