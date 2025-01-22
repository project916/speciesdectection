import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadHistoryPage extends StatefulWidget {
  @override
  _UploadHistoryPageState createState() => _UploadHistoryPageState();
}

class _UploadHistoryPageState extends State<UploadHistoryPage> {
  List<Map<String, dynamic>> videoHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchVideoHistory();
  }

  Future<void> _fetchVideoHistory() async {
    try {
      QuerySnapshot videoSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .orderBy('time', descending: true)
          .get();

      List<Map<String, dynamic>> tempHistory = [];

      for (var videoDoc in videoSnapshot.docs) {
        Map<String, dynamic> videoData = videoDoc.data() as Map<String, dynamic>;
        String userId = videoData['userId'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          tempHistory.add({
            'videoId': videoDoc.id,
            'time': videoData['time'],
            'result': videoData['result'],
            'userName': userData['name'] ?? 'Unknown',
            'userCity': userData['city'] ?? 'Unknown',
            'userEmail': userData['email'] ?? 'Unknown',
            'videoUrl': videoData.containsKey('videoUrl') ? videoData['videoUrl'] : '',
          });
        }
      }

      setState(() {
        videoHistory = tempHistory;
      });
    } catch (e) {
      print("Error fetching video history: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching video history.")),
      );
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
                    title: Text('Uploaded by: ${video['userName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Result: ${video['result']}'),
                        Text('Uploaded on: ${video['time']}'),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoDetailsPage(videoDetails: video),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class VideoDetailsPage extends StatefulWidget {
  final Map<String, dynamic> videoDetails;

  VideoDetailsPage({required this.videoDetails});

  @override
  _VideoDetailsPageState createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoDetails['videoUrl'] != null && widget.videoDetails['videoUrl'].isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoDetails['videoUrl'])
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
        });
    }
  }

  @override
  void dispose() {
    if (_isVideoInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Text('Name: ${widget.videoDetails['userName']}', style: TextStyle(fontSize: 16)),
            Text('Email: ${widget.videoDetails['userEmail']}', style: TextStyle(fontSize: 16)),
            Text('City: ${widget.videoDetails['userCity']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Video Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Text('Result: ${widget.videoDetails['result']}', style: TextStyle(fontSize: 16)),
            Text('Uploaded: ${widget.videoDetails['time']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            if (widget.videoDetails['videoUrl'] != null && widget.videoDetails['videoUrl'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Preview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  SizedBox(height: 10),
                  _isVideoInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : 
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      
                      ElevatedButton(
                        onPressed: () => _launchURL(widget.videoDetails['videoUrl']),
                        child: Text('Open in Browser'),
                      ),
                    ],
                  ),
                ],
              ),
            if (widget.videoDetails['videoUrl'] == null || widget.videoDetails['videoUrl'].isEmpty)
              Center(
                child: Text(
                  'No video URL available.',
                  style: TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
