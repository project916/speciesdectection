import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  AiChatPageState createState() => AiChatPageState();
}

class AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  List<Map<String, dynamic>>? usersPosts;

  @override
  void initState() {
    super.initState();
  }

  final instructions = '''
"instruction"={"system_prompt"  : "Your name is Alert AI. your aim is to assist the user for the user_input . this is the system instruction and i provide app details in app_details. you can understand the app details from there. you must give reply to the user_input." , "app_details": "This project is a comprehensive solution that combines a Flutter mobile application with a Flask backend for animal detection, safety management, and user interaction. The system provides features for users to register, log in securely, and upload videos for analysis. The app uses Firebase Authentication to manage user accounts and Firebase Firestore to store user details, chat messages, emergency contacts, and feedback. Video uploads are processed through the Flask backend, where the YOLOv4 model analyzes each frame to detect elephants or bears, returning the results to the app. Notifications for detection results are sent using OneSignal, ensuring users are promptly informed.

In addition to animal detection, the app offers an array of features for user safety and interaction. Emergency contacts can be added, managed, and accessed quickly during critical situations, promoting user safety. The app also provides safety tips to educate users on precautions related to wildlife encounters. Feedback functionality allows users to share their experiences, helping administrators improve the platform. Users can also edit their profiles to keep their information up to date.

Admins have robust control over the app's ecosystem. They can manage user accounts, including editing or removing user data, oversee emergency contact lists, and moderate user feedback. The admin chat functionality enables direct communication between users and administrators, fostering a supportive and responsive environment. Notifications can be managed and customized to ensure timely communication with users.

The app integrates a chat feature for real-time communication, where users can send and receive messages. The chat history can be cleared, ensuring users have control over their interactions.

In the app we can upload video using by upload video in the homepage,we can edit user profile from profile section"}''';

  void _sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'message': userMessage});
      _isLoading = true;
    });

    String modifiedUserInput =
        '''$instructions,  "user_input": "$userMessage"''';

    try {
      final gemini = Gemini.instance;

      final conversation = [
        ..._chatHistory.map(
          (msg) => Content(
            parts: [Part.text(msg['message']!)],
            role: msg['role'],
          ),
        ),
        Content(
          parts: [Part.text(modifiedUserInput)],
          role: 'user',
        ),
      ];
      final response = await gemini.chat(conversation);
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'role': 'model',
            'message': response?.output ?? 'No response received',
          });
        });
      }
    } catch (e) {
      log('Error in chat: $e');
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'role': 'error',
            'message':
                'Response not loading. Please try again or check your internet connection.',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMessageBubble(String message, String role,
      {bool isLoading = false}) {
    bool isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 18.0),
        decoration: BoxDecoration(
          color: isUser
              ? const Color.fromARGB(255, 48, 77, 159)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: isUser ? const Radius.circular(20.0) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 39, 36, 36).withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                message,
                style: TextStyle(
                  fontSize: 16.0,
                  color: isUser ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        if (index == _chatHistory.length && _isLoading) {
          return _buildMessageBubble('', 'model', isLoading: true);
        }
        final message = _chatHistory[index];
        return _buildMessageBubble(message['message']!, message['role']!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 137, 157, 165),
                Color.fromARGB(255, 191, 160, 158),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('asset/images/logo.jpeg'),
                backgroundColor: Colors.blue,
                radius: 25,
              ),
              SizedBox(width: 10),
              Text(
                'Alert AI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 131, 167, 182),
              Color.fromARGB(255, 198, 152, 152)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _chatHistory.isEmpty
                    ? const Center(
                        child: Text(
                          'Start a conversation with Alert Ai',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 43, 40, 40)),
                        ),
                      )
                    : _buildChatList(),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0)),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 152, 144, 144),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                          minLines: 1,
                          maxLines: 5,
                          onSubmitted: (_) {
                            final message = _controller.text;
                            _controller.clear();
                            _sendMessage(message);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color.fromARGB(255, 9, 36, 82),
                        ),
                        onPressed: () {
                          final message = _controller.text;
                          _controller.clear();
                          _sendMessage(message);
                        },
                        splashColor: Colors.blueAccent.withOpacity(0.3),
                        splashRadius: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
