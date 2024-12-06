import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class UserAuthService{
    final firebaseAuth = FirebaseAuth.instance;
    void UserRegister({required String name,required String email,required String mobile,required String password,required BuildContext context}){
      try{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Registration successfull")));
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Registration Failed")));
      }

    }
}