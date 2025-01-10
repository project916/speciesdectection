import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // For picking files
import 'dart:io'; // For file handling
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobilenumberController = TextEditingController();

  bool showPass = true;
  bool showConfirmPass = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Dropdown-related variables
  final List<String> cities = ['Kannur', 'Iritty', 'Aralam', 'Mattannur'];
  String? selectedCity;

  // Aadhaar file-related variables
  File? aadhaarFile;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Only image files
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        aadhaarFile = File(result.files.single.path!);
      });
    }
  }

 Future<String?> uploadToCloudinary(File file) async {
  const String cloudName = 'duois5umz'; // Replace with your Cloudinary cloud name
  const String apiKey = '275969583223717'; // Replace with your Cloudinary API key
  const String apiSecret = 'YA29IGtIUlFXnid8SunyDNa81-U'; // Replace with your Cloudinary API secret

  // Timestamp for generating the signature
  final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // Generate the signature using the API secret
  final String signature = sha1
      .convert(utf8.encode(
          'timestamp=$timestamp$apiSecret')) // The string to sign
      .toString();

  final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
  final request = http.MultipartRequest('POST', uri);

  // Add required fields
  request.fields['api_key'] = apiKey;
  request.fields['timestamp'] = timestamp.toString();
  request.fields['signature'] = signature;

  // Add file
  request.files.add(await http.MultipartFile.fromPath('file', file.path));

  // Send request
  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = json.decode(await response.stream.bytesToString());
    return responseData['secure_url'];
  } else {
    return null;
  }
}

  void signupHandler() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a city'),
          ),
        );
        return;
      }
      if (aadhaarFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload an Aadhaar photo'),
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        // Upload image to Cloudinary
        String? imageUrl = await uploadToCloudinary(aadhaarFile!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload Aadhaar image'),
            ),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Register user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Store user details in Firestore with pending status
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user?.uid)
            .set({
          'name': nameController.text,
          'email': emailController.text,
          'mobile': mobilenumberController.text,
          'city': selectedCity,
          'aadhaarUrl': imageUrl,
          'status': 'pending', // Add pending status
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful, waiting for admin approval'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix errors in the form'),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    mobilenumberController.dispose();
    super.dispose();
  }

  Widget customTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      IconButton? suffixIcon,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('asset/images/logo.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name TextField
                  customTextField(
                    nameController,
                    'Enter your name',
                    Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  // Email TextField
                  customTextField(
                    emailController,
                    'Email',
                    Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  // Mobile Number TextField
                  customTextField(
                    mobilenumberController,
                    'Mobile',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 10) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),

                  // City Dropdown
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Select City',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      value: selectedCity,
                      items: cities
                          .map((city) => DropdownMenuItem<String>(
                                value: city,
                                child: Text(city),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a city' : null,
                    ),
                  ),

                  // Aadhaar Upload Button
                  aadhaarFile == null
                      ? OutlinedButton.icon(
                          onPressed: pickFile,
                          icon: const Icon(Icons.upload),
                          label: const Text("Upload Aadhaar"),
                        )
                      : Column(
                          children: [
                            Image.file(
                              aadhaarFile!,
                              height: 150,
                              width: 150,
                            ),
                            OutlinedButton.icon(
                              onPressed: pickFile,
                              icon: const Icon(Icons.refresh),
                              label: const Text("Change Aadhaar"),
                            ),
                          ],
                        ),

                  const SizedBox(height: 20),

                  // Password TextField
                  customTextField(
                    passwordController,
                    'Password',
                    Icons.lock,
                    obscureText: showPass,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPass = !showPass;
                        });
                      },
                      icon: Icon(
                          showPass ? Icons.visibility : Icons.visibility_off),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),

                  // Confirm Password TextField
                  customTextField(
                    confirmPasswordController,
                    'Confirm Password',
                    Icons.lock,
                    obscureText: showConfirmPass,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showConfirmPass = !showConfirmPass;
                        });
                      },
                      icon: Icon(showConfirmPass
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Button or Loading Indicator
                  isLoading
                      ? const CircularProgressIndicator()
                      : OutlinedButton(
                          onPressed: signupHandler,
                          child: const Text('Sign Up'),
                        ),

                  const SizedBox(height: 10),

                  // Login Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color.fromARGB(204, 24, 5, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
