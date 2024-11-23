import 'package:flutter/material.dart';

class RemoveUserPage extends StatefulWidget {
  @override
  _RemoveUserListState createState() => _RemoveUserListState();
}

class _RemoveUserListState extends State<RemoveUserPage> {
  List<String> _users = ['User1', 'User2', 'User3']; // Dummy list for testing

  void _removeUser(int index) {
    setState(() {
      _users.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _users.isEmpty
        ? Center(child: Text('No users to remove'))
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(_users[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeUser(index),
                  ),
                ),
              );
            },
          );
  }
}
