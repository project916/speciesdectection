import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadVideoPage extends StatefulWidget {
  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  String? _selectedVideoPath;
  bool _isUploading = false;
  String _result = "Upload a video to detect animals.";
  late String apiValue;

  // Fetch the API value from Firestore
  Future<void> fetchApiValue() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('Bgvx3GwBjwYwMQlzFBwUDAKQMkW2')
          .get();
      setState(() {
        apiValue = doc['api'] ?? '';
      });
    } catch (e) {
      print('Error fetching API value: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchApiValue();
  }

  // Function to pick a video file
  Future<void> _pickVideo(BuildContext context) async {
    try {
      // Pick a video file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        // Access the file path
        String filePath = result.files.single.path!;
        await _uploadVideo();
        setState(() {
          _selectedVideoPath = filePath; // Update the state with the selected file path
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video selected: $filePath')),
        );
      } else {
        // No file was selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No video selected.')),
        );
      }
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  // Function to upload the video and save data to Firestore
  Future<void> _uploadVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        _isUploading = true;
      });

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiValue/upload'), // Replace with your Flask server's URL
      );

      request.files.add(await http.MultipartFile.fromPath('video', file.path));

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var parsedData = jsonDecode(responseData);
          _result = parsedData['result'];

          if (_result == 'notfound') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No Dangerous Animals')),
            );
          } else {
            await sendNotificationToDevice('Alert ', _result);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_result)),
            );
          }

          // Save video details to Firestore
          await saveVideoDetailsToFirestore(_result);
        } else {
          setState(() {
            _result = "Error uploading video.";
          });
        }
      } catch (e) {
        setState(() {
          _result = "Error uploading video: $e";
        });
      } finally {
        setState(() {
          _isUploading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _result = "No video selected.";
      });
    }
  }

  // Function to send notification to users in the same city
  Future<void> sendNotificationToDevice(String title, String body) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print("User not authenticated.");
        return;
      }

      String? userCity = await getCityFromFirestore(uid);

      if (userCity == null) {
        print("User city not found.");
        return;
      }

      print("User's City: $userCity");

      // Fetch playerIds from the playerId collection
      var snapshot = await FirebaseFirestore.instance
          .collection('playerId')
          .where('city', isEqualTo: userCity) // Filter by city
          .get();

      print("Query returned ${snapshot.docs.length} users in the same city.");

      List<String> playerIds = [];
      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('onId')) {
          playerIds.add(doc['onId']);
        }
      }

      if (playerIds.isEmpty) {
        print('No users in the same city to send notifications to.');
        return;
      }

      // Send notification
      var url = Uri.parse('https://api.onesignal.com/notifications');
      var notificationData = {
        "app_id": '892abe75-6f3f-4773-b748-90cf5aaccf2d', // Replace with your OneSignal app ID
        "headings": {"en": title},
        "contents": {"en": body},
        "include_player_ids": playerIds,
      };

      var headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "os_v2_app_revl45lph5dxhn2isdhvvlgpfw5qioeeimuua5eetpb66zztsz7vk3qn2l5zcusid3tapiqnk4cheqnjugqbin4e2z43e6jhtihfhli", // Replace with your OneSignal API Key
      };

      var response = await http.post(url, headers: headers, body: jsonEncode(notificationData));
      print('Player IDs: $playerIds');

      if (response.statusCode == 200) {
        print("Notification Sent Successfully!");
      } else {
        print("Failed to send notification: ${response.statusCode}");
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // Function to get the current user's city from Firestore
  Future<String?> getCityFromFirestore(String? uid) async {
    if (uid == null) {
      return null;
    }

    try {
      var userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        String? city = userDoc.data()?['city'];
        return city;
      } else {
        print('User not found in Firestore');
        return null;
      }
    } catch (e) {
      print('Error fetching user city: $e');
      return null;
    }
  }

  // Function to save video details to Firestore
  Future<void> saveVideoDetailsToFirestore(String result) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print("User not authenticated.");
        return;
      }

      // Get the current time
      String time = DateTime.now().toIso8601String();

      // Save video details to Firestore
      await FirebaseFirestore.instance.collection('videos').add({
        'userId': uid,
        'time': time,
        'result': result,
      });

      print("Video details saved successfully.");
    } catch (e) {
      print("Error saving video details to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Upload'),
        backgroundColor: const Color.fromARGB(255, 68, 236, 255),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.6),
              Colors.lightBlue.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _uploadVideo();
                },
                child: Text('Select Video'),
              ),
              SizedBox(height: 20),
              if (_selectedVideoPath != null)
                Text(
                  'Video Selected: $_selectedVideoPath',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'No video selected yet.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
