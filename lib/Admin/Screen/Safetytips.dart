import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSafetyTipsPage extends StatefulWidget {
  @override
  _AdminSafetyTipsPageState createState() => _AdminSafetyTipsPageState();
}

class _AdminSafetyTipsPageState extends State<AdminSafetyTipsPage> {
  final CollectionReference safetyTipsCollection =
      FirebaseFirestore.instance.collection('Safetytips');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void addSafetyTip() {
    if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
      safetyTipsCollection.add({
        'title': titleController.text,
        'description': descriptionController.text,
      });
      titleController.clear();
      descriptionController.clear();
    }
  }

  void deleteSafetyTip(String id) {
    safetyTipsCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Safety Tips'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addSafetyTip,
              child: Text('Add Safety Tip'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            Expanded(
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
                    itemCount: safetyTips.length,
                    itemBuilder: (context, index) {
                      var tip = safetyTips[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(tip['title']),
                          subtitle: Text(tip['description']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteSafetyTip(tip.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
