import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Emergency_Contact_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Feedbac_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Safety_Tips_Page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Upload_Video_Page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/profile.dart';

/// -------------------------- Homepage Widget --------------------------
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  // Method to build each feature box with icon and title
  Widget buildFeatureBox(
      BuildContext context, String title, IconData icon, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7), // Transparent white for the box
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: const Color.fromARGB(255, 123, 206, 218),
                size: 45), // Soft pink accent color
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, // Increased font size for better visibility
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome To Wild Alert',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(
            255, 201, 167, 105), // Use a soft pink color for the AppBar
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth
                  .instance.currentUser?.uid) // Use the UID of the current user
              .snapshots(), // Real-time updates for the user's data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong!'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('User data not found.'));
            }

            // Get the user's data from Firestore
            var userData = snapshot.data!;
            String name = userData['name'] ?? 'Anonymous';
            String email = userData['email'] ?? 'No email available';

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade100, Colors.orange.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                            'asset/images/profile_image.png'), // Replace with actual image
                      ),
                      SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        email,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {
                    // Implement logout functionality here (clear session, if needed)
                    // Show a SnackBar indicating logout
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged out')),
                    );

                    // Navigate to the LoginPage and remove ProfilePage from the stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Container(
        // Pastel gradient background for the homepage
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 105, 180, 185),
              const Color.fromARGB(255, 106, 160, 161)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Logo Image
            Image.asset(
              'asset/images/logo.jpeg',
              width: MediaQuery.of(context).size.width,
              height: 250,
              fit: BoxFit.fitWidth,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns for 2x2 layout
                  crossAxisSpacing: 16, // Horizontal spacing between items
                  mainAxisSpacing: 16, // Vertical spacing between items
                  childAspectRatio: 1, // Aspect ratio of each item (box)
                ),
                itemCount: 4, // Total 4 feature boxes
                itemBuilder: (context, index) {
                  // Creating 4 feature boxes
                  switch (index) {
                    case 0:
                      return buildFeatureBox(
                        context,
                        'Upload Video',
                        Icons.upload_file,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UploadVideoPage())),
                      );
                    case 1:
                      return buildFeatureBox(
                        context,
                        'Safety Tips',
                        Icons.info_outline,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SafetyTipsPage())),
                      );
                    case 2:
                      return buildFeatureBox(
                        context,
                        'Emergency Contact',
                        Icons.phone_in_talk,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmergencyContactPage())),
                      );
                    case 3:
                      return buildFeatureBox(
                        context,
                        'Feedback',
                        Icons.feedback,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackPage())),
                      );
                    default:
                      return SizedBox(); // Empty box if index is out of bounds
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
