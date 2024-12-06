import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class UserAuthService{
    final firebaseAuth = FirebaseAuth.instance;
    final firestoreDatabase=FirebaseFirestore.instance;
    Future<void> UserRegister({
      required String name,
      required String email,
      required String mobile,
      required String password,
      required BuildContext context}) async {
      try{
        final user= await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password); 
        
        firestoreDatabase.collection("Users").doc(user.user?.uid).set({

          "name" :name,
          "email":email,
          "mobile":mobile,
          "password":password


        });
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Registration successfull")));
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Registration Failed")));
      }

    }
}