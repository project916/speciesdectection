import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speciesdectection/Admin/Screen/Admin_home.dart';
import 'package:speciesdectection/detection%20and%20processing/Service/UserAuthService.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Forgotpassword.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Homepage.dart'; // User home page
import 'package:speciesdectection/detection%20and%20processing/screens/Registration_screen.dart'; // Signup page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = true;
  bool isLoading = false; // Flag for loading state
  final _formKey = GlobalKey<FormState>();

  void Loginhandler() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true; // Start loading
      });

      // Default admin credentials
      const adminEmail = 'admin@gmail.com';
      const adminPassword = 'admin123';

      // Check if admin credentials are entered
      if (emailController.text.trim() == adminEmail &&
          passwordController.text == adminPassword) {
        // Navigate to Admin Homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHome(), // Admin home page widget
          ),
        );
      } else {
        // Authenticate regular user
        bool loginSuccess = await UserAuthService().userLogin(
          email: emailController.text.trim(),
          password: passwordController.text,
          context: context,
        );

        if (loginSuccess) {
          // Check if the logged-in user is a regular user
          String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

          if (userEmail == adminEmail) {
            // Admin user, navigate to Admin Homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminHome(),
              ),
            );
          } else {
            // Regular user, navigate to User Homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Homepage(), // User home page widget
              ),
            );
          }
        }
      }

      setState(() {
        isLoading = false; // Stop loading
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix errors in the form'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Custom text field for the login form
  Widget customTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    IconButton? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
            offset: Offset(0, 4),
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
            colors: [
              Colors.blue.shade50,
              const Color.fromARGB(255, 249, 219, 144),
            ],
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
                  // Circular logo image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('asset/images/logo.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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

                  // Password TextField with visibility toggle
                  customTextField(
                    passwordController,
                    'Password',
                    Icons.lock,
                    obscureText: showPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: Icon(showPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()));
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: const Color.fromARGB(190, 119, 44, 126)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button or Loading Indicator
                  isLoading
                      ? CircularProgressIndicator() // Show loading spinner
                      : OutlinedButton(
                          onPressed: Loginhandler,
                          child: Text('Login'),
                        ),
                  const SizedBox(height: 10),

                  // Sign Up Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the Signup page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Signup(),
                            ),
                          );
                        },
                        child: Text(
                          "Signup",
                          style: TextStyle(
                            color: const Color.fromARGB(204, 24, 5, 78),
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
