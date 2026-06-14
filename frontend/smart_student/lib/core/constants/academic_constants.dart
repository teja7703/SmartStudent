class AcademicConstants {
  AcademicConstants._();

  static const List<String> academicLevels = [
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'Inter 1st Year',
    'Inter 2nd Year',
  ];

  static const List<String> subjects = [
    'Mathematics',
    'Science',
    'Social',
    'English',
    'Telugu',
    'Hindi',
  ];

  static String formatLevel(String level) {
    return level.contains('Inter') ? level : 'Class $level';
  }
}
