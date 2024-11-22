import 'package:flutter/material.dart';

class SystemSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('System Settings')),
      body: Center(
        child: Text('Here you can modify system settings'),
      ),
    );
  }
}
