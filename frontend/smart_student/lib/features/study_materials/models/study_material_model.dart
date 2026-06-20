class StudyMaterialModel {
  final String id;
  final String title;
  final String chapter;
  final String content;
  final String pdfUrl;
  final String videoUrl;
  final String academicLevel;
  final String subject;
  final String language;

  StudyMaterialModel({
    required this.id,
    required this.title,
    required this.chapter,
    required this.content,
    required this.pdfUrl,
    required this.videoUrl,
    this.academicLevel = '',
    this.subject = '',
    this.language = 'English',
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
    academicLevel: json['academicLevel'] ?? '',
    subject: json['subject'] ?? '',
    language: json['language'] ?? 'English',
  );
}
}