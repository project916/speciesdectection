import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String mobile,
    required String city,
    required String aadhaarImageUrl,
  }) async {
    try {
      // Create a user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

     

      // Store user data in Firestore with 'pending' status
      await FirebaseFirestore.instance.collection('Users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'city': city,
        'aadhaarUrl': aadhaarImageUrl,
        'status': 'pending', // Status will be pending until admin approval
      });

      // Store the playerId in the 'playerId' collection
      
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // Log in an existing user
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final playerId = OneSignal.User.pushSubscription.id;
      String? city = await getCityFromFirestore(userCredential.user?.uid);

      // Store the playerId in the 'playerId' collection
      if (playerId != null) {
        await FirebaseFirestore.instance.collection('playerId').doc(userCredential.user?.uid).set({
          'onId': playerId,
          'city':city,
        });
      }

      return userCredential;
    } catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }

  // Check if the user is signed in
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Log out the current user
  Future<void> logOut() async {
    await _auth.signOut();
  }

  // Approve user by changing their status to 'approved'
  Future<void> approveUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'status': 'approved',
      });
    } catch (e) {
      print("Error approving user: $e");
    }
  }

  // Reject user by changing their status to 'rejected'
  Future<void> rejectUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'status': 'rejected',
      });
    } catch (e) {
      print("Error rejecting user: $e");
    }
  }

  // Check if the current user is approved
  Future<bool> isUserApproved(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      return userDoc.exists && userDoc['status'] == 'approved';
    } catch (e) {
      print("Error checking user status: $e");
      return false;
    }
  }

  // Check if the current user is logged in
  Future<bool> isUserLoggedIn() async {
    User? user = await getCurrentUser();
    return user != null;
  }

  // User login method (updated for use in LoginPage)
  Future<bool> userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential? userCredential = await login(email: email, password: password);
      if (userCredential != null) {
        // After successful login, check if the user is approved or not
        bool isApproved = await isUserApproved(userCredential.user?.uid ?? '');
        if (isApproved) {
          return true; // Login successful and user is approved
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Your account is pending approval.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password.")),
        );
      }
      return false; // Login failed
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }
}
 Future<String?> getCityFromFirestore(String? uid) async {
  if (uid == null) {
    return null; // Return null if the uid is not provided
  }

  try {
    // Fetch the current user document from Firestore using the uid
    var userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (userDoc.exists) {
      // Retrieve the city from the user document
      String? city = userDoc.data()?['city'];
      return city; // Return the city
    } else {
      print('User not found in Firestore');
      return null; // Return null if the user document doesn't exist
    }
  } catch (e) {
    print('Error fetching user city: $e');
    return null; // Return null if an error occurs
  }
}