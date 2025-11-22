import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile.dart';
import '../models/user_events.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  // -------------------------
  // Helper: Load UserProfile from Firestore
  // -------------------------
  Future<UserProfile> _loadUserProfile(String firebaseUid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUid)
        .get();

    if (!doc.exists) {
      throw Exception("User profile not found.");
    }

    return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
  }

  // -------------------------
  // Email + Password Login
  // -------------------------
  Future<void> _loginWithEmail() async {
    setState(() => loading = true);

    try {
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firebaseUid = cred.user!.uid;

      // Load profile
      UserProfile profile = await _loadUserProfile(firebaseUid);

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/home", // replace with your home route
          arguments: profile,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  // -------------------------
  // Google Sign-In Login
  // -------------------------
  Future<void> _loginWithGoogle() async {
    setState(() => loading = true);

    try {
      // Step 1: Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(scopes: ['email']).signIn();

      if (googleUser == null) {
        setState(() => loading = false);
        return; // user cancelled
      }

      // Step 2: Get Google auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Build Firebase credentials
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Step 4: Sign in to Firebase
      UserCredential cred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseUid = cred.user!.uid;

      // Step 5: If new user → create default profile
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUid)
          .get();

      UserProfile profile;

      if (!doc.exists) {
        profile = UserProfile(
          id: firebaseUid, // reuse UID as internal ID
          username: googleUser.email.split("@")[0],
          displayName: googleUser.displayName ?? "",
          email: googleUser.email,
          profilePhoto: googleUser.photoUrl ?? "",
          country: "",
          state: "",
          city: "",
          friends: [],
          events: [],
        );

        // Create Firestore document
        await FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUid)
            .set(profile.toJson());
      } else {
        // Load existing profile
        profile = UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/home",
          arguments: profile,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Login failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : _loginWithEmail,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loading ? null : _loginWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
