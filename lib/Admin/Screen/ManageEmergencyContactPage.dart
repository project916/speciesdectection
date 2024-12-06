import 'package:flutter/material.dart';

class ManageEmergencyContactPage extends StatefulWidget {
  @override
  _ManageEmergencyContactPageState createState() => _ManageEmergencyContactPageState();
}

class _ManageEmergencyContactPageState extends State<ManageEmergencyContactPage> {
  final List<String> _contacts = ['John Doe - 1234567890', 'Jane Smith - 9876543210']; // Sample emergency contacts

  void _addContact(String contact) {
    setState(() {
      _contacts.add(contact);
    });
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Emergency Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onSubmitted: _addContact,
              decoration: InputDecoration(
                labelText: 'Add Emergency Contact',
                suffixIcon: Icon(Icons.add),
              ),
            ),
            SizedBox(height: 20),
            _contacts.isEmpty
                ? Center(child: Text('No emergency contacts available'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(_contacts[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeContact(index),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
