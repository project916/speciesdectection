import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:speciesdectection/Admin/Screen/Admin_home.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Homepage.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.initialize("892abe75-6f3f-4773-b748-90cf5aaccf2d");
  await OneSignal.Notifications.requestPermission(true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
        future: FirebaseAuth.instance
            .authStateChanges()
            .first, // Listen to authentication state
        builder: (context, snapshot) {
          // Check if the user is logged in
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator while waiting
          }

          if (snapshot.hasData) {
            // User is logged in, check their role
            return FutureBuilder<bool>(
              future: checkUserRole(snapshot
                  .data!.email), // Check if the user is admin or regular user
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while checking role
                }

                if (roleSnapshot.data == true) {
                  return AdminHome(); // If admin, navigate to Admin homepage
                } else {
                  return Homepage(); // If regular user, navigate to User homepage
                }
              },
            );
          } else {
            // User is not logged in, show login screen
            return LoginPage();
          }
        },
      ),
    );
  }

  // Function to check user role (admin or regular user)
  Future<bool> checkUserRole(String? userEmail) async {
    if (userEmail == null) return false;

    // Check if the email exists in the admin collection
    var adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(userEmail)
        .get();
    if (adminDoc.exists) {
      return true; // User is an admin
    }

    // Check if the email exists in the user collection
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .get();
    if (userDoc.exists) {
      return false; // User is a regular user
    }

    return false; // Default: user is neither admin nor regular user
  }
}
