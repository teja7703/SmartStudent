import 'dart:io';

class ApiConstants {
  ApiConstants._();

  static const bool isProduction = true;

  static String get baseUrl {
    if (isProduction) {
      return 'https://smartstudent-api-seu5.onrender.com';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  static String get authLogin => '$baseUrl/api/auth/login';
  static String get dashboard => '$baseUrl/api/dashboard';
  static String get studyMaterials => '$baseUrl/api/study-materials';
  static String get previousPapers => '$baseUrl/api/previous-papers';
  static String get careers => '$baseUrl/api/careers';
  static String get stories => '$baseUrl/api/stories';
  static String get quizzes => '$baseUrl/api/quizzes';
}