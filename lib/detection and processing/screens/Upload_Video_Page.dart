import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:onesignal_flutter/onesignal_flutter.dart';

class UploadVideoPage extends StatefulWidget {
  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  String? _selectedVideoPath; // Store the selected video path
  bool _isUploading = false;
  // Function to pick a video file
  Future<void> _pickVideo(BuildContext context) async {
    try {
      // Attempt to pick a video file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video, // Specify video files
      );

      if (result != null && result.files.single.path != null) {
        // Access the file path
        String filePath = result.files.single.path!;
        await _uploadVideo();
        setState(() {
          _selectedVideoPath =
              filePath; // Update the state with the selected file path
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

  String _result = "Upload a video to detect animals.";

  Future<void> _uploadVideo() async {
    // Pick a video file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        _isUploading = true; // Start upload
      });

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://acea-103-181-40-109.ngrok-free.app/upload'), // Replace with your Flask server's URL
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
          _isUploading = false; // Upload complete
        });
        Navigator.of(context).pop(); // Close loading dialog
      }
    } else {
      setState(() {
        _result = "No video selected.";
      });
    }
  }

  Future<void> sendNotificationToDevice(String title, String body) async {
    const String oneSignalRestApiKey =
        'os_v2_app_revl45lph5dxhn2isdhvvlgpfw5qioeeimuua5eetpb66zztsz7vk3qn2l5zcusid3tapiqnk4cheqnjugqbin4e2z43e6jhtihfhli';
    const String oneSignalAppId = '892abe75-6f3f-4773-b748-90cf5aaccf2d';

    var status = await FirebaseFirestore.instance.collection('playerId').get();

    var snapshot =
        await FirebaseFirestore.instance.collection('playerId').get();

    List<String> playerIds =
        []; // Loop through each document and extract the 'onId' field
    for (var doc in snapshot.docs) {
      if (doc.data().containsKey('onId')) {
        playerIds.add(doc['onId']);
      }
    }
    var url = Uri.parse('https://api.onesignal.com/notifications?c=push');
    var notificationData = {
      "app_id": oneSignalAppId,
      "headings": {"en": title},
      "contents": {"en": body},
      "target_channel": "push",
      "include_player_ids": playerIds
    };
    print('hhhh');
    var headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $oneSignalRestApiKey",
    };
    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(notificationData),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print("Notification Sent Successfully!");
        print(response.body);
      } else {
        print("Failed to send notification: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Upload'),
        backgroundColor: const Color.fromARGB(
            255, 68, 236, 255), // Set AppBar background color
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
              // Display the selected video information
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
