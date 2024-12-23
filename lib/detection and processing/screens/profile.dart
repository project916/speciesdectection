import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/EditProfilePage.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart'; // Import LoginPage

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('data not available');
            } else {
              final profiledata = snapshot.data?.data();
              print(profiledata);
              return Container(
                // Use a Container for the background
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // Linear Gradient
                    colors: [
                      const Color.fromARGB(255, 85, 115, 167),
                      const Color.fromARGB(255, 151, 155, 103)
                    ], // Gradient colors
                    begin: Alignment.topLeft, // Gradient start point
                    end: Alignment.bottomRight, // Gradient end point
                  ),
                ),
                child: Center(
                  // Center the content vertically
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the content vertically
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center content horizontally
                      children: [
                        // Profile Picture (CircleAvatar)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                              'asset/images/profile_image.png'), // Replace with actual image asset path
                        ),
                        SizedBox(height: 20),

                        // User Name
                        Text(
                          profiledata!['name'],
                          // Replace with actual user data
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 10),

                        // User Email
                        Text(
                          profiledata[
                              'email'], // Replace with actual user email
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        SizedBox(height: 20),

                        // Edit Profile Button
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the EditProfilePage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage()),
                            );
                          },
                          child: Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            // Log out the user using Firebase Auth
                            await FirebaseAuth.instance.signOut();

                            // Optionally, clear any other session data, like SharedPreferences (if used)
                            // Example: SharedPreferences.remove('key'); if you're storing data locally

                            // Show a SnackBar indicating logout
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logged out')),
                            );

                            // Navigate to the LoginPage and remove all routes from the stack (so the user can't go back to the home page)
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LoginPage(), // Navigate to LoginPage
                              ),
                              (route) =>
                                  false, // Remove all previous routes from the stack (no back navigation)
                            );
                          },
                          child: Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ));
  }
}
