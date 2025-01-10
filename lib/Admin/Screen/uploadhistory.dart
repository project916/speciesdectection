import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UploadHistoryPage extends StatefulWidget {
  @override
  _UploadHistoryPageState createState() => _UploadHistoryPageState();
}

class _UploadHistoryPageState extends State<UploadHistoryPage> {
  // To store videos and their associated user details
  List<Map<String, dynamic>> videoHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchVideoHistory();
  }

  // Fetch video history and user details
  Future<void> _fetchVideoHistory() async {
    try {
      // Get all video records from the 'videos' collection
      QuerySnapshot videoSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .orderBy('time', descending: true) // Order by time (most recent first)
          .get();

      // List to store video and user details
      List<Map<String, dynamic>> tempHistory = [];

      for (var videoDoc in videoSnapshot.docs) {
        // Get user details using the userId from the video record
        String userId = videoDoc['userId'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .get();

        // If user details are found, add them to the video data
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          tempHistory.add({
            'videoId': videoDoc.id,
            'time': videoDoc['time'],
            'result': videoDoc['result'],
            'userName': userData['name'] ?? 'Unknown',
            'userCity': userData['city'] ?? 'Unknown',
            'userEmail': userData['email'] ?? 'Unknown',
          });
        }
      }

      setState(() {
        videoHistory = tempHistory;
      });
    } catch (e) {
      print("Error fetching video history: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching video history.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload History'),
        backgroundColor: Colors.blueAccent,
      ),
      body: videoHistory.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videoHistory.length,
              itemBuilder: (context, index) {
                var video = videoHistory[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('Video ID: ${video['videoId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Uploaded by: ${video['userName']}'),
                        Text('Email: ${video['userEmail']}'),
                        Text('City: ${video['userCity']}'),
                        Text('Result: ${video['result']}'),
                        Text('Time: ${video['time']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
