import 'package:flutter/material.dart';
import 'package:speciesdectection/Admin/AdminChat.dart';
import 'package:speciesdectection/Admin/Screen/Adminprivileage.dart';
import 'package:speciesdectection/Admin/Screen/ManageUsersPage.dart';
import 'package:speciesdectection/Admin/Screen/ViewFeedbackPage.dart';
import 'package:speciesdectection/Admin/Screen/ManageEmergencyContactPage.dart';
import 'package:speciesdectection/Admin/Screen/SendNotificationsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/Admin/AdminChat.dart';

import 'api.dart'; // Import Admin Chat Page

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
        title: Text('Admin Dashboard'),
        backgroundColor: const Color.fromARGB(255, 53, 185, 168),
        elevation: 0,
        actions: [
          // Logout Icon
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          // Chat Icon
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminChatPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.pink.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return AdminPrivilegeCard(
                title: _getPrivilegeTitle(index),
                icon: _getPrivilegeIcon(index),
                onTap: () => _onPrivilegeTapped(index, context),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ApiScreen()),
        ),
        child: Icon(Icons.settings),
        tooltip: 'Go to Admin Page',
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
      default:
        return 'Privilege $index';
    }
  }

  Icon _getPrivilegeIcon(int index) {
    switch (index) {
      case 0:
        return Icon(Icons.group);
      case 1:
        return Icon(Icons.feedback);
      case 2:
        return Icon(Icons.notifications);
      case 3:
        return Icon(Icons.phone);
      default:
        return Icon(Icons.lock);
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
      default:
        print('Invalid privilege');
    }
  }
}

class AdminPrivilegeCard extends StatelessWidget {
  final String title;
  final Icon icon;
  final VoidCallback onTap;

  AdminPrivilegeCard(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.pink.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
