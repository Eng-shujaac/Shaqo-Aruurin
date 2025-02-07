import 'package:dulimad_diyarid/components/button.dart';
import 'package:dulimad_diyarid/components/textfield.dart';
import 'package:dulimad_diyarid/helpers/database_helper.dart';
import 'package:dulimad_diyarid/models/user.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Database helper instance
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Sign user in function
  void signUserIn(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      _showMessage(context, "Please enter both username and password.");
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

    try {
      // Check user credentials
      var userData = await _databaseHelper.getUser(username, password);

      // Close loading dialog
      Navigator.pop(context);

      if (userData != null) {
        // Convert to User model
        final user = User.fromMap(userData);

        // Clear the text fields
        usernameController.clear();
        passwordController.clear();

        // Navigate to HomePage and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: user),
          ),
          (route) => false,
        );
      } else {
        _showMessage(context, "Invalid username or password");
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showMessage(context, "Login failed. Please try again.");
    }
  }

  // Show message in a Snackbar
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20),

                // Welcome back message
                Text(
                  'Welcome Back To Safar Kaab',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 15),

                // Username text field
                Textfield(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password text field
                Textfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                // Sign in button
                Button(
                  text: 'Sign In',
                  onTap: () => signUserIn(context),
                ),

                const SizedBox(height: 20),

                // Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not registered? ',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Register now',
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
