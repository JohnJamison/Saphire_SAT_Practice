import 'package:flutter/material.dart';
import '../data/fake_users.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<UserProfile> friends = [];
  String query = "";

  @override
  Widget build(BuildContext context) {
    final results = allUsers
        .where((u) =>
            u.name.toLowerCase().contains(query.toLowerCase()) &&
            !friends.contains(u))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search users…",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (s) => setState(() => query = s),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Your Friends",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...friends.map((u) => ListTile(
                      leading: Text(u.avatar, style: const TextStyle(fontSize: 28)),
                      title: Text(u.name),
                    )),
                const Divider(height: 32),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Add Friends",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...results.map((u) => ListTile(
                      leading:
                          Text(u.avatar, style: const TextStyle(fontSize: 28)),
                      title: Text(u.name),
                      trailing: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            friends.add(u);
                            query = "";
                          });
                        },
                        child: const Text("Add"),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
