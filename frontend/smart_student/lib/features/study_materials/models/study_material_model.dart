class StudyMaterialModel {
  final String id;
  final String title;
  final String chapter;
  final String content;
  final String pdfUrl;
  final String videoUrl;

  StudyMaterialModel({
    required this.id,
    required this.title,
    required this.chapter,
    required this.content,
    required this.pdfUrl,
    required this.videoUrl,
  });

  factory StudyMaterialModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudyMaterialModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      chapter: json['chapter'] ?? '',
      content: json['content'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}