import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfilePage extends StatelessWidget {
  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Username: ${profile.username}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),

            Text(
              "Email Address: ${profile.emailAddress}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}