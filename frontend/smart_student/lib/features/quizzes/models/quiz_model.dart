class QuizModel {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final String classLevel;
  final String difficulty;
  final int points;

  QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.classLevel,
    required this.difficulty,
    required this.points,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['_id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? '',
      classLevel: json['classLevel'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
      points: json['points'] ?? 10,
    );
  }
}
