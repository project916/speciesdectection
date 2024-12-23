import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Emergency_Contact_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Feedbac_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Noticationpage.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Safety_Tips_Page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Upload_Video_Page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/UserChat.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/profile.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome To Wild Alert',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 201, 167, 105),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              // Navigate to ChatPage
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatPage()), // Navigate to the ChatPage
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
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
                        backgroundImage:
                            AssetImage('asset/images/profile_image.png'),
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
                  onTap: () async {
                    try {
await FirebaseFirestore.instance.collection('playerId') .doc(FirebaseAuth.instance.currentUser?.uid).delete();
 await FirebaseAuth.instance.signOut();
   ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged out')),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
 print("User logged out successfully.");
} catch (e) {
 print("Error logging out: $e");
 }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged out')),
                    );
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
            Image.asset(
              'asset/images/logo.jpeg',
              width: MediaQuery.of(context).size.width,
              height: 250,
              fit: BoxFit.fitWidth,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
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
                      return SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureBox(
      BuildContext context, String title, IconData icon, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
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
                color: const Color.fromARGB(255, 123, 206, 218), size: 45),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
