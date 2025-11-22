import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import '../../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserModel.instance;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(

        child: Column(

          children: [
            // ---------------- HEADER ----------------
            Container(

              width: double.infinity,
              height: screenHeight * 0.3,
              padding: const EdgeInsets.fromLTRB(100, 60, 20, 30),
              
              decoration: BoxDecoration(
                
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 126, 8, 8),
                    const Color.fromARGB(255, 126, 8, 8).withOpacity(0.9),
                    const Color.fromARGB(255, 126, 8, 8),
                    const Color.fromARGB(255, 223, 101, 101).withOpacity(0.9)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                
              ),

              child: Row(

                children: [

                  // Profile photo circle
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: Text(
                      
                      user.displayInitials,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Name
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Location / username line (like reference image subtext)
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- STATS ROW ----------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statColumn("Accuracy", "${user.accuracy}%"),
                      _statColumn("Avg Time", "${user.avgTime}s"),
                      _statColumn("Estimate", "${user.scoreEstimate}"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Edit Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text("Edit Profile"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- COLLECTION SECTION ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Collection",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: [
                  _collectionCard("Math", Colors.blue),
                  _collectionCard("Reading", Colors.purple),
                  _collectionCard("Writing", Colors.orange),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- TAGS SECTION ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tags",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _tag("Math"),
                  _tag("Speed"),
                  _tag("Reading"),
                  _tag("Practice"),
                  _tag("Daily"),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------- COMPONENTS ----------------

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _collectionCard(String title, Color color) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: const DecorationImage(
          image: AssetImage("assets/placeholder_bg.jpg"),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}
