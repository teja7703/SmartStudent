class StoryModel {
  final String id;
  final String name;
  final String title;
  final String category;
  final String summary;
  final String successLesson;
  final String quote;
  final String imageUrl;
  final int readTime;
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.name,
    required this.title,
    required this.category,
    required this.summary,
    required this.successLesson,
    required this.quote,
    required this.imageUrl,
    required this.readTime,
    required this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary']?.toString() ??
        json['description']?.toString() ??
        '';
    final rawReadTime = (json['readTime'] as num?)?.toInt();
    return StoryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['author']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      summary: summary,
      successLesson: json['successLesson']?.toString() ?? '',
      quote: json['quote']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      readTime: rawReadTime ?? _estimateReadTime(summary),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  static int _estimateReadTime(String text) {
    if (text.isEmpty) return 1;
    final words = text.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 180).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}
