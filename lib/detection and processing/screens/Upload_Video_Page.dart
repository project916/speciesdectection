import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        setState(() {
          _selectedVideoPath = filePath;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video selected: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No video selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  // Function to upload the video to Cloudinary
  Future<String?> _uploadVideoToCloudinary(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/duois5umz/video/upload'),
      );

      request.fields['upload_preset'] = 'video123'; // Replace with your Cloudinary upload preset
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var parsedData = jsonDecode(responseData);
        print("Cloudinary Response: $parsedData");

        // Extract the video URL
        return parsedData['secure_url']; // Ensure this key matches Cloudinary's response structure
      } else {
        print("Error uploading to Cloudinary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  // Function to upload the video and save data to Firestore
  Future<void> _uploadVideo() async {
    if (_selectedVideoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No video selected.')),
      );
      return;
    }

    File file = File(_selectedVideoPath!);

    setState(() {
      _isUploading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    String? videoUrl = await _uploadVideoToCloudinary(_selectedVideoPath!);

    if (videoUrl == null) {
      setState(() {
        _result = "Error uploading video to Cloudinary.";
      });
      setState(() {
        _isUploading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiValue/upload'),
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
          await sendNotificationToDevice('Alert', _result);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_result)),
          );
        }

        await saveVideoDetailsToFirestore(_result, videoUrl); // Pass video URL here
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
  }

  Future<void> sendNotificationToDevice(String title, String body) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      String formattedTime = DateFormat('HH:mm:ss yyyy-MM-dd').format(DateTime.now());


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

      var snapshot = await FirebaseFirestore.instance
          .collection('playerId')
          .where('city', isEqualTo: userCity)
          .get();

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

      var url = Uri.parse('https://api.onesignal.com/notifications');
      var notificationData = {
        "app_id": '892abe75-6f3f-4773-b748-90cf5aaccf2d',
        "headings": {"en": title},
        "contents": {"en": "$body\nTime: $formattedTime"},
        "include_player_ids": playerIds,
      };

      var headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "os_v2_app_revl45lph5dxhn2isdhvvlgpfw5qioeeimuua5eetpb66zztsz7vk3qn2l5zcusid3tapiqnk4cheqnjugqbin4e2z43e6jhtihfhli",
      };

      var response = await http.post(url, headers: headers, body: jsonEncode(notificationData));
      print('Player IDs: $playerIds');

      if (response.statusCode == 200) {
        print("Notification Sent Successfully!");
      } else {
        print("Failed to send notification: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

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

  Future<void> saveVideoDetailsToFirestore(String result, String videoUrl) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print("User not authenticated.");
        return;
      }

      String time = DateTime.now().toIso8601String();

      await FirebaseFirestore.instance.collection('videos').add({
        'userId': uid,
        'time': time,
        'result': result,
        'videoUrl': videoUrl, // Save the video URL
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
                  await _pickVideo(context);
                },
                child: Text('Select Video'),
              ),
              SizedBox(height: 20),
              if (_selectedVideoPath != null) ...[
                Text(
                  'Video Selected: $_selectedVideoPath',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _uploadVideo();
                  },
                  child: Text('Process Video'),
                ),
              ] else
                Text(
                  'No video selected yet.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              
              if (_isUploading)
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
