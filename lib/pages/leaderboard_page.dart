import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class Player {
  final String name;
  final int score;

  Player({required this.name, required this.score});
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // -------------------------------
  // FILTERS
  // -------------------------------
  String locationFilter = "Global";
  String modeFilter = "Ranked";
  String subjectFilter = "All";

  final List<String> locationOptions = ["Global", "State", "Local"];
  final List<String> modeOptions = ["Ranked", "Practice", "Speedrun"];
  final List<String> subjectOptions = ["All", "Math", "Reading", "Writing"];

  // --------------------------------
  // MOCK DATA — replace with real API / Firestore queries
  // --------------------------------
  List<Player> allPlayers = [
    Player(name: "Jane", score: 1900),
    Player(name: "Mia", score: 1750),
    Player(name: "Ethan", score: 1600),
    Player(name: "Lucas", score: 1580),
    Player(name: "Sofia", score: 1520),
  ];

  List<Player> filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    applyFilters();
  }

  // --------------------------------
  // Apply filters to ranking data
  // (replace this logic with real backend queries)
  // --------------------------------
  void applyFilters() {
    setState(() {
      // In real version: you'd fetch new data based on filters.
      // Here we simply sort for demonstration.
      filteredPlayers = [...allPlayers];
      filteredPlayers.sort((a, b) => b.score.compareTo(a.score));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboards"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // -------------------------------
          // FILTERS UI
          // -------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildDropdown("Location", locationOptions, locationFilter, (val) {
                locationFilter = val!;
                applyFilters();
              }),
              buildDropdown("Mode", modeOptions, modeFilter, (val) {
                modeFilter = val!;
                applyFilters();
              }),
              buildDropdown("Subject", subjectOptions, subjectFilter, (val) {
                subjectFilter = val!;
                applyFilters();
              }),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(),

          // -------------------------------
          // RANKINGS LIST
          // -------------------------------
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlayers.length,
              itemBuilder: (context, index) {
                final rank = index + 1;
                final p = filteredPlayers[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(rank.toString()),
                  ),
                  title: Text(p.name),
                  trailing: Text(
                    p.score.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build dropdowns
  Widget buildDropdown(
    String label,
    List<String> options,
    String selected,
    Function(String?) onChanged,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selected,
          items: options.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
