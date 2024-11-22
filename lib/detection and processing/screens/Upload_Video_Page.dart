import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadVideoPage extends StatefulWidget {
  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  String? _selectedVideoPath; // Store the selected video path

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Upload')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _pickVideo(context), // Trigger the video picker
              child: Text('Select Video'),
            ),
            SizedBox(height: 20),
            // Display the selected video information
            if (_selectedVideoPath != null)
              Text(
                'Video Selected: $_selectedVideoPath',
                style: TextStyle(fontSize: 16),
              )
            else
              Text(
                'No video selected yet.',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
