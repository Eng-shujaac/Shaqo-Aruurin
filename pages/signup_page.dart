import 'package:dulimad_diyarid/components/button.dart';
import 'package:dulimad_diyarid/components/textfield.dart';
import 'package:dulimad_diyarid/helpers/database_helper.dart';
import 'package:flutter/material.dart';


class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  // Text editing controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void signUserUp(BuildContext context) async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validate inputs
    if (fullName.isEmpty || email.isEmpty || username.isEmpty || 
        password.isEmpty || confirmPassword.isEmpty) {
      _showMessage(context, "Please fill in all fields.");
      return;
    }

    // Full name validation
    if (fullName.length < 3) {
      _showMessage(context, "Full name must be at least 3 characters long.");
      return;
    }

    // Email validation
    if (!isValidEmail(email)) {
      _showMessage(context, "Please enter a valid email address.");
      return;
    }

    // Username validation
    if (username.length < 3) {
      _showMessage(context, "Username must be at least 3 characters long.");
      return;
    }

    // Password validation
    if (password.length < 6) {
      _showMessage(context, "Password must be at least 6 characters long.");
      return;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      _showMessage(context, "Password must contain at least one uppercase letter.");
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      _showMessage(context, "Password must contain at least one number.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage(context, "Passwords do not match.");
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Initialize the DatabaseHelper
    final dbHelper = DatabaseHelper();

    try {
      // Insert user into the database
      await dbHelper.insertUser(
        username,
        password,
        fullName: fullName,
        email: email,
      );

      // Close loading dialog
      Navigator.pop(context);
      
      _showMessage(context, "Registration successful!");
      
      // Clear the text fields
      fullNameController.clear();
      emailController.clear();
      usernameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      
      // Navigate back to Login Page after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      if (e.toString().contains('Username already exists')) {
        _showMessage(context, "Username already taken. Please choose another one.");
      } else {
        _showMessage(context, "Registration failed. Please try again.");
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 20),

                // Welcome message
                Text(
                  'Create a New Account',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name text field
                Textfield(
                  controller: fullNameController,
                  hintText: 'Full Name',
                  obscureText: false,
                ),
                const SizedBox(height: 15),

                // Email text field
                Textfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 15),

                // Username text field
                Textfield(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 15),

                // Password text field
                Textfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 15),

                // Confirm password text field
                Textfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),

                // Sign up button
                Button(
                  text: 'Sign Up',
                  onTap: () => signUserUp(context),
                ),
                const SizedBox(height: 25),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
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
    );
  }
}
