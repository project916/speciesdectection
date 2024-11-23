import 'package:flutter/material.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserFormState createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _addUser() {
    final name = _nameController.text;
    final email = _emailController.text;
    final phoneNumber = _phoneController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phoneNumber.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    _showSuccessDialog('User added successfully!');
  }

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
                Navigator.pop(context); // Go back to Manage Users page
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
    return SingleChildScrollView(
      child: Column(
        key: ValueKey('addUserForm'),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Enter Name'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Enter Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Enter Phone Number'),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Enter Password'),
            obscureText: true,
          ),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addUser,
            child: Text('Add User'),
          ),
        ],
      ),
    );
  }
}
