import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  // Create controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  // Firebase Auth and Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store the original values to reset fields
  String originalName = '';
  String originalMobile = '';
  String profileImageUrl = ''; // Store profile image URL (default or uploaded)

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // Fetch user data from Firebase
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Get the user document from the 'Users' collection
      DocumentSnapshot snapshot =
          await _firestore.collection('Users').doc(user.uid).get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          originalName = data['name'] ?? '';
          originalMobile = data['mobile'] ?? '';
          profileImageUrl =
              data['profileImageUrl'] ?? ''; // Set the profile image URL

          _nameController.text = originalName;
          _mobileController.text = originalMobile;
        });
      }
    }
  }

  // Update user profile data
  Future<void> _updateUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Update the user data in Firestore
        await _firestore.collection('Users').doc(user.uid).update({
          'name': _nameController.text,
          'mobile': _mobileController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  // Reset the fields to their original values
  void _resetFields() {
    setState(() {
      _nameController.text = originalName;
      _mobileController.text = originalMobile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlueAccent.withOpacity(0.3),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          // Wrap the body with SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // To make sure content doesn't take up all the space
                children: [
                  // Profile Picture (optional: you can add a picker here)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(
                            profileImageUrl) // Use the user's image if available
                        : AssetImage('assets/images/default_profile.png')
                            as ImageProvider, // Default image if no profile picture
                  ),
                  SizedBox(height: 20),

                  // User Name Field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Mobile Number Field
                  TextField(
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Save Changes Button
                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    child: Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Reset Button
                  ElevatedButton(
                    onPressed: _resetFields,
                    child: Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.grey,
                      textStyle: TextStyle(
                          fontSize: 18), // Grey color for reset button
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
