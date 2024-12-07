import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EmergencyContactPage extends StatelessWidget {
  final List<Map<String, String>> emergencyContacts = [
    {
      'name': 'Police',
      'phone': '100',
    },
    {
      'name': 'Ambulance',
      'phone': '102',
    },
    {
      'name': 'Fire Brigade',
      'phone': '101',
    },
    {
      'name': 'Wildlife Helpline',
      'phone': '1800-123-4567',
    },
    {
      'name': 'Forest Department',
      'phone': '1800-987-6543',
    },
  ];

  /// Function to open the phone dialer
  Future<void> _openDialer(String phoneNumber) async {
    final Uri dialerUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(dialerUri)) {
      await launchUrl(dialerUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.withOpacity(0.1),
              Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: emergencyContacts.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text(
                  emergencyContacts[index]['name']!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Phone: ${emergencyContacts[index]['phone']}'),
                trailing: Icon(Icons.call, color: Colors.blue),
                onTap: () {
                  _openDialer(emergencyContacts[index]['phone']!);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
