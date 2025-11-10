import 'package:flutter/material.dart';

class StreakHeader extends StatelessWidget {
  final int streakDays;
  const StreakHeader({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    final streakColor = streakDays >= 5
        ? const Color(0xFFFFB300) // gold for 5+ days
        : const Color(0xFFB80F0A); // red for shorter streaks

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department, color: streakColor, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔥 $streakDays-Day Streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Keep up the consistency!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
