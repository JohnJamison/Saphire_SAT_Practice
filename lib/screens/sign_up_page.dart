import 'package:flutter/material.dart';
import 'dart:math';
import '../models/profile.dart';
import '../services/profile_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text controllers for all input fields
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final passwordController = TextEditingController();
  final profilePhotoController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Generates a random user ID (just here for now should remove later)
  String generateUserId() {
    final rand = Random();
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(12, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your Account"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput("Username", usernameController),
            _buildInput("Display Name", displayNameController),
            _buildInput("Password", passwordController, isPassword: true),
            _buildInput("Profile Photo URL (optional)", profilePhotoController),
            _buildInput("Country", countryController),
            _buildInput("State", stateController),
            _buildInput("City", cityController),
            _buildInput("Email Address", emailController),
            _buildInput("Phone Number", phoneController, isNumber: true),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Create Account"),
              onPressed: () async {
                String userId = generateUserId();

                Profile newProfile = Profile(
                  usernameController.text.trim(),
                  displayNameController.text.trim(),
                  passwordController.text.trim(),
                  profilePhotoController.text.trim().isEmpty
                      ? "assets/default_profile.png"
                      : profilePhotoController.text.trim(),
                  countryController.text.trim(),
                  stateController.text.trim(),
                  cityController.text.trim(),
                  emailController.text.trim(),
                  int.tryParse(phoneController.text.trim()) ?? 0,
                  userId,
                  [],
                  [],
                );

                // ⚡ AUTO-SAVE TO FIRESTORE
                await ProfileService.saveProfile(newProfile);

                // Return the profile (optional)
                Navigator.pop(context, newProfile);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget builder for text inputs
  Widget _buildInput(String label, TextEditingController controller,
      {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

}
