import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:speciesdectection/Admin/Screen/Admin_home.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Homepage.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

const apiKey = 'AIzaSyCn03KnBa4kLko9bqh9FCnIvkW4BrxvwPI';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.initialize("892abe75-6f3f-4773-b748-90cf5aaccf2d");
  await OneSignal.Notifications.requestPermission(true);
  Gemini.init(apiKey: apiKey);
  // Determine the initial screen dynamically
  final homeScreen = await determineHomeScreen();

  runApp(MyApp(home: homeScreen));
}

Future<Widget> determineHomeScreen() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      // Check if the user is an admin
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: user.email)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        return AdminHome(); // Admin home screen
      }

      // Check the user's status in the 'Users' collection
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid) // Use user.uid for the document ID
          .get();

      String statusData = userDoc.data()?['status'] ?? 'pending';
      bool status = statusData == 'approved';

      if (status) {
        return Homepage(); // User home screen
      } else {
        return LoginPage(); // If status is not approved, show login
      }
    } catch (e) {
      print('Error checking user role or status: $e');
      return LoginPage(); // Fallback to login on error
    }
  } else {
    return LoginPage(); // Login screen for unauthenticated users
  }
}

class MyApp extends StatelessWidget {
  final Widget home;

  MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
