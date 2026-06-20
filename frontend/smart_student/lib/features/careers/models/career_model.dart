class CareerModel {
  final String id;
  final String careerName;
  final String category;
  final String description;
  final String overview;
  final String eligibility;
  final String requiredEducation;
  final String salaryRange;
  final List<String> skills;
  final String careerGrowth;
  final List<String> recommendedCourses;
  final String imageUrl;

  CareerModel({
    required this.id,
    required this.careerName,
    required this.category,
    required this.description,
    required this.overview,
    required this.eligibility,
    required this.requiredEducation,
    required this.salaryRange,
    required this.skills,
    required this.careerGrowth,
    required this.recommendedCourses,
    required this.imageUrl,
  });

  /// Overview text with a sensible fallback to the short description.
  String get overviewOrDescription =>
      overview.isNotEmpty ? overview : description;

  /// Eligibility text with a sensible fallback to required education.
  String get eligibilityOrEducation =>
      eligibility.isNotEmpty ? eligibility : requiredEducation;

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id: json['_id']?.toString() ?? '',
      careerName: json['careerName']?.toString() ?? '',
      category: (json['category']?.toString().isNotEmpty ?? false)
          ? json['category'].toString()
          : 'General',
      description: json['description']?.toString() ?? '',
      overview: json['overview']?.toString() ?? '',
      eligibility: json['eligibility']?.toString() ?? '',
      requiredEducation: json['requiredEducation']?.toString() ?? '',
      salaryRange: json['salaryRange']?.toString() ?? '',
      skills: List<String>.from(json['skills'] ?? const []),
      careerGrowth: json['careerGrowth']?.toString() ?? '',
      recommendedCourses:
          List<String>.from(json['recommendedCourses'] ?? const []),
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}
