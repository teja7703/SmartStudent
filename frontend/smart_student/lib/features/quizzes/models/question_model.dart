class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final String classLevel;
  final String difficulty;
  final int points;

  const QuestionModel({
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

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: List<String>.from(json['options'] ?? const []),
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      classLevel: json['classLevel']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'Easy',
      points: (json['points'] is num) ? (json['points'] as num).toInt() : 10,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'category': category,
        'classLevel': classLevel,
        'difficulty': difficulty,
        'points': points,
      };
}
