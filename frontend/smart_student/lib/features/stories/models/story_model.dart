class StoryModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final int readTime;

  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.readTime,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      readTime: json['readTime'] ?? 5,
    );
  }
}
