import 'package:flutter/material.dart';
import 'package:speciesdectection/Admin/Adminprivileage.dart';
import 'package:speciesdectection/Admin/ManageContentPage.dart';
import 'package:speciesdectection/Admin/ManageUsersPage.dart';
import 'package:speciesdectection/Admin/SendNotificationsPage';
import 'package:speciesdectection/Admin/SystemSettingsPage';
import 'package:speciesdectection/Admin/ViewAnalyticsPage';
import 'package:speciesdectection/Admin/ViewTransactionsPage';
import 'manage_users_page.dart';
import 'view_analytics_page.dart';
import 'system_settings_page.dart';
import 'view_transactions_page.dart';
import 'send_notifications_page.dart';
import 'manage_content_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items in a row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 6, // Number of privileges
          itemBuilder: (context, index) {
            return AdminPrivilegeCard(
              title: _getPrivilegeTitle(index),
              icon: _getPrivilegeIcon(index),
              onTap: () => _onPrivilegeTapped(index, context),
            );
          },
        ),
      ),
    );
  }

  String _getPrivilegeTitle(int index) {
    switch (index) {
      case 0:
        return 'Manage Users';
      case 1:
        return 'View Analytics';
      case 2:
        return 'System Settings';
      case 3:
        return 'View Transactions';
      case 4:
        return 'Send Notifications';
      case 5:
        return 'Manage Content';
      default:
        return 'Privilege $index';
    }
  }

  Icon _getPrivilegeIcon(int index) {
    switch (index) {
      case 0:
        return Icon(Icons.group);
      case 1:
        return Icon(Icons.analytics);
      case 2:
        return Icon(Icons.settings);
      case 3:
        return Icon(Icons.payment);
      case 4:
        return Icon(Icons.notifications);
      case 5:
        return Icon(Icons.content_paste);
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
          MaterialPageRoute(builder: (context) => ViewAnalyticsPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SystemSettingsPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewTransactionsPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SendNotificationsPage()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageContentPage()),
        );
        break;
      default:
        print('Invalid privilege');
    }
  }
}
