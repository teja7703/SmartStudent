class PreviousPaperModel {
  final String id;
  final String academicLevel;
  final String subject;
  final int year;
  final String paperType;
  final String pdfUrl;

  PreviousPaperModel({
    required this.id,
    required this.academicLevel,
    required this.subject,
    required this.year,
    required this.paperType,
    required this.pdfUrl,
  });

  factory PreviousPaperModel.fromJson(Map<String, dynamic> json) {
    return PreviousPaperModel(
      id: json['_id'] ?? '',
      academicLevel: json['academicLevel'] ?? '',
      subject: json['subject'] ?? '',
      year: json['year'] ?? 0,
      paperType: json['paperType'] ?? 'Public Exam',
      pdfUrl: json['pdfUrl'] ?? '',
    );
  }
}
