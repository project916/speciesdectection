import 'package:flutter/material.dart';
import 'package:speciesdectection/Admin/Screen/AddUser.dart';
import 'RemoveUser.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  bool _isAddingUser = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Users')),
      body: Container(
        // Gradient background for the entire page
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 181, 202, 218),
              const Color.fromARGB(255, 208, 215, 214)
            ], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle buttons to switch between Add and Remove User pages
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingUser = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isAddingUser ? Colors.blue : Colors.grey,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    child: Text(
                      'Add User',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingUser = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isAddingUser ? Colors.blue : Colors.grey,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    child: Text(
                      'Remove User',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // AnimatedSwitcher for smooth transition between sections
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _isAddingUser ? AdminApprovalPage() : RemoveUserPage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
