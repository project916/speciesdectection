import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:speciesdectection/Admin/Screen/Admin_home.dart';
import 'package:speciesdectection/Admin/Screen/Admin_login.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Homepage.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Registration_screen.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home:Signup()));
}
