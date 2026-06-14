class DashboardModel {
  final int totalStories;
  final int totalCareers;
  final int totalQuizzes;
  final int totalStudyMaterials;
  final int totalPreviousPapers;

  DashboardModel({
    required this.totalStories,
    required this.totalCareers,
    required this.totalQuizzes,
    required this.totalStudyMaterials,
    required this.totalPreviousPapers,
  });

  factory DashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardModel(
      totalStories: json['totalStories'] ?? 0,
      totalCareers: json['totalCareers'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
      totalStudyMaterials:
          json['totalStudyMaterials'] ?? 0,
      totalPreviousPapers:
          json['totalPreviousPapers'] ?? 0,
    );
  }
}