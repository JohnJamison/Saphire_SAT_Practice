import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../models/user_events.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();

  bool loading = false;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      /// 1. Create Firebase Auth user
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firebaseUid = cred.user!.uid;

      /// 2. Generate your own internal user ID
      final internalUserId = const Uuid().v4();

      /// 3. Build UserProfile object
      UserProfile profile = UserProfile(
        id: internalUserId,
        username: usernameController.text.trim(),
        displayName: displayNameController.text.trim(),
        email: emailController.text.trim(),
        profilePhoto: "", // default for now
        country: countryController.text.trim(),
        state: stateController.text.trim(),
        city: cityController.text.trim(),
        friends: [],
        events: [],
      );

      /// 4. Store in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUid)
          .set(profile.toJson());

      if (mounted) {
        Navigator.pop(context); // or go to home page
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (v) => v!.isEmpty ? "Enter username" : null,
              ),
              TextFormField(
                controller: displayNameController,
                decoration: const InputDecoration(labelText: "Display Name"),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.contains("@") ? null : "Invalid email",
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? "Password must be 6+ chars" : null,
              ),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(labelText: "Country"),
              ),
              TextFormField(
                controller: stateController,
                decoration: const InputDecoration(labelText: "State"),
              ),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : _createAccount,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
