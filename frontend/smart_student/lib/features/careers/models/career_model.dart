class CareerModel {
  final String id;
  final String careerName;
  final String description;
  final String requiredEducation;
  final String salaryRange;
  final List<String> skills;
  final String imageUrl;

  CareerModel({
    required this.id,
    required this.careerName,
    required this.description,
    required this.requiredEducation,
    required this.salaryRange,
    required this.skills,
    required this.imageUrl,
  });

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id: json['_id'] ?? '',
      careerName: json['careerName'] ?? '',
      description: json['description'] ?? '',
      requiredEducation: json['requiredEducation'] ?? '',
      salaryRange: json['salaryRange'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
