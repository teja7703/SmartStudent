class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String name;
  final String photoUrl;
  final int points;
  final int streak;
  final String role;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.points,
    required this.streak,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'Student',
      photoUrl: json['photoUrl'] ?? '',
      points: json['points'] ?? 0,
      streak: json['streak'] ?? 0,
      role: json['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firebaseUid': firebaseUid,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'points': points,
        'streak': streak,
        'role': role,
      };

  String get firstName => name.split(' ').first;
}
