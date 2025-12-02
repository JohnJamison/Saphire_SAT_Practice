class QuestionAttempt {
  final String userId;
  final String questionId;
  final String mainCategory;     // math, reading, writing
  final String subCategory;      // algebra, geometry, grammar, etc.
  final bool correct;
  final String answerChoice;     // A/B/C/D
  final String gameMode;         // classic, lightning, streaks...
  final int durationMs;          // time to answer
  final DateTime timestamp;      // when it was answered

  QuestionAttempt({
    required this.userId,
    required this.questionId,
    required this.mainCategory,
    required this.subCategory,
    required this.correct,
    required this.answerChoice,
    required this.gameMode,
    required this.durationMs,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "questionId": questionId,
      "mainCategory": mainCategory,
      "subCategory": subCategory,
      "correct": correct,
      "answerChoice": answerChoice,
      "gameMode": gameMode,
      "durationMs": durationMs,
      "timestamp": timestamp,
    };
  }
}
