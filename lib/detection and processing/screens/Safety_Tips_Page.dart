import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SafetyTipsPage extends StatelessWidget {
  final CollectionReference safetyTipsCollection =
      FirebaseFirestore.instance.collection('Safetytips');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Tips'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.lightGreenAccent.withOpacity(0.2),
        child: StreamBuilder<QuerySnapshot>(
          stream: safetyTipsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No safety tips available.'));
            }
            var safetyTips = snapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: safetyTips.length,
              itemBuilder: (context, index) {
                var tip = safetyTips[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: Colors.orangeAccent,
                      size: 30,
                    ),
                    title: Text(
                      tip['title'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      tip['description'],
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}