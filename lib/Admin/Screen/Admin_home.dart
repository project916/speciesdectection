import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speciesdectection/Admin/AdminChat.dart';
import 'package:speciesdectection/Admin/Screen/ManageUsersPage.dart';
import 'package:speciesdectection/Admin/Screen/Safetytips.dart';
import 'package:speciesdectection/Admin/Screen/ViewFeedbackPage.dart';
import 'package:speciesdectection/Admin/Screen/ManageEmergencyContactPage.dart';
import 'package:speciesdectection/Admin/Screen/SendNotificationsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speciesdectection/Admin/Screen/uploadhistory.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'api.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 254, 171),
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3F7FF), Color(0xFFFFE3E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 7, // Number of features
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () => _onPrivilegeTapped(index, context),
                child: AdminFeatureCard(
                  title: _getPrivilegeTitle(index),
                  icon: _getPrivilegeIcon(index),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ApiScreen()),
        ),
        backgroundColor: const Color(0xFF35B9A8),
        child: const Icon(Icons.settings),
        tooltip: 'Admin Settings',
      ),
    );
  }

  String _getPrivilegeTitle(int index) {
    switch (index) {
      case 0:
        return 'Manage Users';
      case 1:
        return 'View Feedback';
      case 2:
        return 'Send Notifications';
      case 3:
        return 'Manage Emergency Contact';
      case 4:
        return 'Upload History';
      case 5:
        return 'User Chat';
      case 6:
        return 'Manage Safety Tips';
      default:
        return 'Privilege $index';
    }
  }

  IconData _getPrivilegeIcon(int index) {
    switch (index) {
      case 0:
        return Icons.group;
      case 1:
        return Icons.feedback;
      case 2:
        return Icons.notifications;
      case 3:
        return Icons.phone;
      case 4:
        return Icons.history;
      case 5:
        return Icons.chat;
      case 6:
        return Icons.safety_check;
      default:
        return Icons.lock;
    }
  }

  void _onPrivilegeTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageUsersPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewFeedbackPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SendNotificationsPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageEmergencyContactPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UploadHistoryPage()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminChatPage()),
        );
        break;
      case 6:
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>AdminSafetyTipsPage()), // Use the correct class name
  );
  break;

      default:
        print('Invalid privilege');
    }
  }
}


class AdminFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const AdminFeatureCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.black12,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB8D3FF), Color(0xFFD7A8F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                icon,
                size: 30,
                color: Color(0xFF5A5A5A),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }
}
