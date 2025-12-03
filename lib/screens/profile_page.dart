import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import '../../models/user_model.dart';
import 'friends_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Which SAT section we’re looking at in the stats area.
enum SatSection { math, reading, writing }

extension SatSectionX on SatSection {
  String get label {
    switch (this) {
      case SatSection.math:
        return 'Math';
      case SatSection.reading:
        return 'Reading';
      case SatSection.writing:
        return 'Writing';
    }
  }

  String get firestoreKey {
    switch (this) {
      case SatSection.math:
        return 'Math';
      case SatSection.reading:
        return 'Reading';
      case SatSection.writing:
        return 'Writing';
    }
  }
}

/// Internal aggregate data.
class _SectionAgg {
  int total = 0;
  int correct = 0;
  int totalTimeMs = 0;

  int weekTotal = 0;
  int weekCorrect = 0;
  int prevWeekTotal = 0;
  int prevWeekCorrect = 0;

  int monthTotal = 0;
  int monthCorrect = 0;
  int prevMonthTotal = 0;
  int prevMonthCorrect = 0;

  final Map<String, _SubcatAgg> subcats = {};
}

/// Subcategory stats.
class _SubcatAgg {
  int total = 0;
  int correct = 0;
  int totalTimeMs = 0;

  int weekTotal = 0;
  int weekCorrect = 0;

  int monthTotal = 0;
  int monthCorrect = 0;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userFuture;
  SatSection _selectedSection = SatSection.math;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  // =============================
  // LOAD USER + FRIENDS + STATS
  // =============================
  Future<Map<String, dynamic>> _loadUserData() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) throw Exception("Not logged in");

    final uid = authUser.uid;

    // User data
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final user = userDoc.data() ?? {};

    // Attempts collection
    final attemptsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('attempts')
        .get();

    final attempts = attemptsSnap.docs.map((d) => d.data()).toList();

    final total = attempts.length;
    final correct = attempts.where((a) => (a['correct'] == true)).length;
    final accuracy = total == 0 ? 0 : (correct / total * 100).round();

    final avgTimeMs = total == 0
        ? 0
        : attempts.map((a) => (a['timeMs'] ?? 0)).reduce((s, v) => s + v) ~/ total;

    // Section aggregation
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final prevWeekAgo = now.subtract(const Duration(days: 14));
    final monthAgo = now.subtract(const Duration(days: 30));
    final prevMonthAgo = now.subtract(const Duration(days: 60));

    final Map<String, _SectionAgg> sectionAgg = {
      'Math': _SectionAgg(),
      'Reading': _SectionAgg(),
      'Writing': _SectionAgg(),
    };

    String _normalizeSection(String? raw) {
      final v = (raw ?? '').toLowerCase();
      if (v.startsWith('math')) return 'Math';
      if (v.startsWith('read')) return 'Reading';
      if (v.startsWith('writ')) return 'Writing';
      return 'Math';
    }

    for (final a in attempts) {
      final sec = _normalizeSection(a['section'] ?? a['sectionMode']);
      final secAgg = sectionAgg[sec] ??= _SectionAgg();

      final isCorrect = a['correct'] == true;
      final int timeMs = (a['timeMs'] ?? 0).toInt();
      final subName = a['subcategory'] ?? 'General';

      secAgg.total++;
      if (isCorrect) secAgg.correct++;
      secAgg.totalTimeMs += timeMs;

      final subAgg = secAgg.subcats[subName] ??= _SubcatAgg();
      subAgg.total++;
      if (isCorrect) subAgg.correct++;
      subAgg.totalTimeMs += timeMs;

      DateTime? ts;
      if (a["timestamp"] is Timestamp) ts = (a["timestamp"] as Timestamp).toDate();

      if (ts != null) {
        if (ts.isAfter(weekAgo)) {
          secAgg.weekTotal++;
          if (isCorrect) secAgg.weekCorrect++;
          subAgg.weekTotal++;
          if (isCorrect) subAgg.weekCorrect++;
        } else if (ts.isAfter(prevWeekAgo)) {
          secAgg.prevWeekTotal++;
          if (isCorrect) secAgg.prevWeekCorrect++;
        }

        if (ts.isAfter(monthAgo)) {
          secAgg.monthTotal++;
          if (isCorrect) secAgg.monthCorrect++;
          subAgg.monthTotal++;
          if (isCorrect) subAgg.monthCorrect++;
        } else if (ts.isAfter(prevMonthAgo)) {
          secAgg.prevMonthTotal++;
          if (isCorrect) secAgg.prevMonthCorrect++;
        }
      }
    }

    double _ratio(int c, int t) => t == 0 ? 0.0 : (c / t * 100);

    final Map<String, dynamic> sectionStats = {};
    sectionAgg.forEach((name, agg) {
      final avgTimeSec = agg.total == 0 ? 0.0 : agg.totalTimeMs / agg.total / 1000.0;

      final weekAcc = _ratio(agg.weekCorrect, agg.weekTotal);
      final prevWeekAcc =
          agg.prevWeekTotal == 0 ? 0.0 : _ratio(agg.prevWeekCorrect, agg.prevWeekTotal);

      final monthAcc = _ratio(agg.monthCorrect, agg.monthTotal);
      final prevMonthAcc =
          agg.prevMonthTotal == 0 ? 0.0 : _ratio(agg.prevMonthCorrect, agg.prevMonthTotal);

      final Map<String, dynamic> subcatMap = {};
      agg.subcats.forEach((sub, sAgg) {
        subcatMap[sub] = {
          "total": sAgg.total,
          "correct": sAgg.correct,
          "accuracy": _ratio(sAgg.correct, sAgg.total),
          "avgTimeSec":
              sAgg.total == 0 ? 0.0 : sAgg.totalTimeMs / sAgg.total / 1000.0,
          "weeklyAccuracy": _ratio(sAgg.weekCorrect, sAgg.weekTotal),
          "monthlyAccuracy": _ratio(sAgg.monthCorrect, sAgg.monthTotal),
        };
      });

      sectionStats[name] = {
        "total": agg.total,
        "correct": agg.correct,
        "accuracy": _ratio(agg.correct, agg.total),
        "avgTimeSec": avgTimeSec,
        "weeklyChange": weekAcc - prevWeekAcc,
        "monthlyChange": monthAcc - prevMonthAcc,
        "subcategories": subcatMap,
      };
    });

    // Friends
    final friendIds = List<String>.from(user["friends"] ?? []);
    List<Map<String, dynamic>> friends = [];

    for (final fid in friendIds) {
      final fDoc = await FirebaseFirestore.instance.collection('users').doc(fid).get();
      if (fDoc.exists) {
        friends.add({
          "uid": fid,
          "displayName": fDoc["displayName"] ?? "",
          "username": fDoc["username"] ?? "",
        });
      }
    }

    return {
      "username": user["username"] ?? "",
      "displayName": user["displayName"] ?? "",
      "email": user["email"] ?? "",
      "number": user["number"] ?? "",
      "location": user["location"] ?? {},
      "photoUrl": user["photoUrl"] ?? "",

      "totalQuestions": total,
      "totalCorrect": correct,
      "accuracy": accuracy,
      "avgTime": (avgTimeMs / 1000).toStringAsFixed(1),

      "sectionStats": sectionStats,

      "friends": friends,
    };
  }

  // ============================================
  // BUILD UI
  // ============================================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snap.data!;
        final displayName = user["displayName"] ?? "";
        final username = user["username"] ?? "";
        final accuracy = user["accuracy"] ?? 0;
        final avgTime = user["avgTime"] ?? "0.0";
        final totalQuestions = user["totalQuestions"] ?? 0;
        final totalCorrect = user["totalCorrect"] ?? 0;

        final initials = displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : "?";

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ====================================================
                // HEADER (new UI)
                // ====================================================
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 196, 18, 18),
                        const Color.fromARGB(255, 196, 18, 18).withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: (user["photoUrl"] != null &&
                                user["photoUrl"].toString().isNotEmpty)
                            ? NetworkImage(user["photoUrl"])
                            : null,
                        child: (user["photoUrl"] == null ||
                                user["photoUrl"].toString().isEmpty)
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(width: 18),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _statColumn("Accuracy", "$accuracy%"),
                            const SizedBox(width: 40),
                            _statColumn("Avg Time", "${avgTime}s"),
                            const SizedBox(width: 40),
                            _statColumn("Estimate", "$accuracy"),
                          ],
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfilePage()),
                          );
                          if (updated == true) {
                            setState(() => _userFuture = _loadUserData());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text("Edit Profile"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ====================================================
                // FRIENDS SECTION (merged)
                // ====================================================
                _sectionTitle("Friends"),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [

                      // SEARCH BAR
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search friends...",
                          filled: true,
                          fillColor: const Color.fromARGB(255, 219, 213, 213),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // HORIZONTAL BUBBLES
                      SizedBox(
                        height: (user["friends"] as List).isEmpty ? 0 : 90,
                        child: (user["friends"] as List).isEmpty
                            ? const SizedBox.shrink()
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (user["friends"] as List).length,
                                itemBuilder: (context, i) {
                                  final f = (user["friends"] as List)[i]
                                      as Map<String, dynamic>;
                                  final name = f["displayName"] ?? "";
                                  final initial = name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : "?";
                                  return _friendBubble(name, initial);
                                },
                              ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showFriendsPopup(
                            context,
                            (user["friends"] as List)
                                .cast<Map<String, dynamic>>(),
                          ),
                          child: const Text("View All"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FriendsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Find Friends",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ====================================================
                // BIG STATS AREA (unchanged)
                // ====================================================
                _buildStatsSection(user, totalQuestions, totalCorrect),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SUPPORTING UI WIDGETS (same as your new page)
  // ============================================================
  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _friendBubble(String name, String initial) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  void _showFriendsPopup(BuildContext context, List<Map<String, dynamic>> friends) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Your Friends"),
        content: SizedBox(
          width: 300,
          height: 350,
          child: friends.isEmpty
              ? const Center(child: Text("You have no friends added yet."))
              : ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, i) {
                    final f = friends[i];
                    final name = f["displayName"] ?? "";
                    final username = f["username"] ?? "";
                    final initial = name.isNotEmpty
                        ? name[0].toUpperCase()
                        : "?";

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        child: Text(initial),
                      ),
                      title: Text(name),
                      subtitle: Text(username),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // =========================== NEW STATS UI ===========================
  Widget _buildStatsSection(Map<String, dynamic> user, int totalQ, int totalC) {
    final stats = user["sectionStats"] ?? {};
    final sec = stats[_selectedSection.label] ?? {};
    final subcats = sec["subcategories"] ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Performance Overview",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),
          const SizedBox(height: 12),

          _buildSubjectTabs(),
          const SizedBox(height: 20),

          _buildTopRowMetrics(sec, totalQ, totalC),
          const SizedBox(height: 20),

          _buildSubjectSummaryCards(sec),
          const SizedBox(height: 30),

          _buildBestAndWorstSection(subcats),
          const SizedBox(height: 24),

          _buildSubcategoryTable(subcats),
        ],
      ),
    );
  }

  Widget _buildSubjectTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: SatSection.values.map((s) {
          final selected = _selectedSection == s;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedSection = s),
              borderRadius: BorderRadius.circular(20),
              child: _SubjectTab(label: s.label, selected: selected),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopRowMetrics(Map<String, dynamic> sec, int totalQ, int totalC) {
    final tot = sec["total"] ?? 0;
    final cor = sec["correct"] ?? 0;
    final acc = sec["accuracy"] ?? 0.0;

    return Row(
      children: [
        Expanded(child: _miniMetricCard("Average Score", "${acc.toStringAsFixed(0)}%")),
        const SizedBox(width: 12),
        Expanded(child: _miniMetricCard("Total Qs", "$tot")),
        const SizedBox(width: 12),
        Expanded(child: _miniMetricCard("Correct", "$cor")),
      ],
    );
  }

  Widget _buildSubjectSummaryCards(Map<String, dynamic> sec) {
    final week = sec["weeklyChange"] ?? 0.0;
    final month = sec["monthlyChange"] ?? 0.0;

    String fmt(double v) =>
        v == 0 ? "+0%" : "${v > 0 ? '+' : ''}${v.toStringAsFixed(1)}%";

    return Column(
      children: [
        _wideStatCard("Weekly Improvement", fmt(week), Icons.trending_up),
        const SizedBox(height: 14),
        _wideStatCard("Monthly Improvement", fmt(month), Icons.calendar_month),
      ],
    );
  }

  Widget _buildBestAndWorstSection(Map<String, dynamic> subcats) {
    if (subcats.isEmpty) {
      return const Text("No subcategory data yet.");
    }

    MapEntry<String, dynamic>? best;
    MapEntry<String, dynamic>? worst;

    subcats.forEach((name, data) {
      final acc = (data["accuracy"] ?? 0.0) as double;
      if (best == null || acc > best!.value["accuracy"]) {
        best = MapEntry(name, data);
      }
      if (worst == null || acc < worst!.value["accuracy"]) {
        worst = MapEntry(name, data);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Subcategory Performance",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (best != null)
          _subcategoryBar("Best", best!.key,
              best!.value["accuracy"] ?? 0.0, Colors.green),
        const SizedBox(height: 12),
        if (worst != null)
          _subcategoryBar("Needs Work", worst!.key,
              worst!.value["accuracy"] ?? 0.0, Colors.orange),
      ],
    );
  }

  Widget _buildSubcategoryTable(Map<String, dynamic> subcats) {
    if (subcats.isEmpty) return const SizedBox.shrink();

    final sorted = subcats.entries.toList()
      ..sort((a, b) => (a.value["accuracy"] ?? 0.0)
          .compareTo(b.value["accuracy"] ?? 0.0))
      ..reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("All Subcategories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),

        ...sorted.map((e) {
          final name = e.key;
          final d = e.value;
          final tot = d["total"] ?? 0;
          final cor = d["correct"] ?? 0;
          final acc = d["accuracy"] ?? 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Correct: $cor / $tot"),
                      Text("Accuracy: ${acc.toStringAsFixed(0)}%"),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _subcategoryBar(String label, String name, double v, Color c) {
    final pct = v.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: pct / 100,
            minHeight: 10,
            color: c,
            backgroundColor: c.withOpacity(0.15),
          ),

          const SizedBox(height: 6),
          Text("${pct.toStringAsFixed(0)}%"),
        ],
      ),
    );
  }

  Widget _wideStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.redAccent),
          const SizedBox(width: 18),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                )),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _SubjectTab({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.redAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
