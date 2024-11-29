import 'package:flutter/material.dart';
import 'package:speciesdectection/Admin/Adminprivileage.dart';
import 'package:speciesdectection/Admin/ManageUsersPage.dart';
import 'package:speciesdectection/Admin/ViewFeedbackPage.dart'; // Assuming you will create this page
import 'package:speciesdectection/Admin/ManageEmergencyContactPage.dart'; // Assuming you will create this page
import 'package:speciesdectection/Admin/SendNotificationsPage.dart';

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
        backgroundColor: const Color.fromARGB(
            255, 53, 185, 168), // Changed to deep purple for contrast
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade100,
              Colors.pink.shade50
            ], // Soft, mild gradient from light blue to soft pink
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: 4, // Now only 4 privileges
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
    );
  }

  String _getPrivilegeTitle(int index) {
    switch (index) {
      case 0:
        return 'Manage Users';
      case 1:
        return 'View Feedback'; // Replaced 'View Analytics' with 'View Feedback'
      case 2:
        return 'Send Notifications';
      case 3:
        return 'Manage Emergency Contact'; // Replaced 'System Settings' with 'Manage Emergency Contact'
      default:
        return 'Privilege $index';
    }
  }

  Icon _getPrivilegeIcon(int index) {
    switch (index) {
      case 0:
        return Icon(Icons.group);
      case 1:
        return Icon(Icons.feedback); // Icon for View Feedback
      case 2:
        return Icon(Icons.notifications);
      case 3:
        return Icon(Icons.phone); // Icon for Manage Emergency Contact
      default:
        return Icon(Icons.lock);
    }
  }

  void _onPrivilegeTapped(int index, BuildContext context) {
    // Handle navigation or actions when a privilege is tapped
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
          MaterialPageRoute(
              builder: (context) =>
                  ViewFeedbackPage()), // Navigate to View Feedback page
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
          MaterialPageRoute(
              builder: (context) =>
                  ManageEmergencyContactPage()), // Navigate to Manage Emergency Contact page
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
            colors: [
              Colors.lightBlue.shade100,
              Colors.pink.shade50
            ], // Soft, mild gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.1), // Mild shadow for a soft effect
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
                color: Colors.black, // Black text for good contrast
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
