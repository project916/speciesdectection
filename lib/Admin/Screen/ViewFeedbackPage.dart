import 'package:flutter/material.dart';

class ViewFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 10, // Example: 10 feedback items
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text('Feedback from User ${index + 1}'),
                subtitle: Text('This is the feedback content for user ${index + 1}.'),
              ),
            );
          },
        ),
      ),
    );
  }
}
