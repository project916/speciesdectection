import 'package:flutter/material.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Emergency_Contact_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Feedbac_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Safety_Tips_Page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Upload_Video_Page.dart';
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
        width: 150,
        height: 150,
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 98, 103, 118).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(255, 38, 79, 150), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: const Color.fromARGB(255, 68, 127, 255), size: 40),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
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
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                          'assets/profile_image.png'), // Replace with actual image
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Profile',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      'A@example.com',
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
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Add action for Settings
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  // Add action for Logout
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Image.asset('asset/images/logo.jpeg',
                width: MediaQuery.of(context).size.width,
                height: 250,
                fit: BoxFit.fitWidth),
            Expanded(
              child: Wrap(
                children: [
                  // Feature boxes
                  buildFeatureBox(
                    context,
                    'Upload Video',
                    Icons.upload_file,
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UploadVideoPage()));
                    },
                  ),
                  buildFeatureBox(
                    context,
                    'Safety Tips',
                    Icons.info_outline,
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SafetyTipsPage()));
                    },
                  ),
                  buildFeatureBox(
                    context,
                    'Emergency Contact',
                    Icons.phone_in_talk,
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmergencyContactPage()));
                    },
                  ),
                  buildFeatureBox(
                    context,
                    'Feedback',
                    Icons.feedback,
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedbackPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
