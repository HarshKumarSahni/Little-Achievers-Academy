import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;
  
  // Student Details
  final String classLevel;
  final String? schoolName;
  final String? address;
  final String? phoneNumber;
  
  // Guardian Details
  final String? guardianName;
  final String? guardianPhone;

  final String? bio;
  final UserStats stats;
  final Timestamp createdAt;
  final bool isProfileComplete;

  UserProfile({
    required this.id,
    this.name,
    this.email,
    this.photoUrl,
    required this.classLevel,
    this.schoolName,
    this.address,
    this.phoneNumber,
    this.guardianName,
    this.guardianPhone,
    this.bio,
    required this.stats,
    required this.createdAt,
    this.isProfileComplete = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, String id) {
    return UserProfile(
      id: id,
      name: json['name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      classLevel: json['classLevel'] as String? ?? "",
      schoolName: json['schoolName'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      guardianName: json['guardianName'] as String?,
      guardianPhone: json['guardianPhone'] as String?,
      bio: json['bio'] as String?,
      stats: json['stats'] != null 
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : UserStats.empty(),
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt'] as Timestamp
          : Timestamp.now(),
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'classLevel': classLevel,
      'schoolName': schoolName,
      'address': address,
      'phoneNumber': phoneNumber,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'bio': bio,
      'stats': stats.toJson(),
      'createdAt': createdAt,
      'isProfileComplete': isProfileComplete,
    };
  }
}

class UserStats {
  final int quizzesTaken;
  final int totalScore;
  final int questionsSolved;

  UserStats({
    required this.quizzesTaken,
    required this.totalScore,
    required this.questionsSolved,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      quizzesTaken: json['quizzesTaken'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      questionsSolved: json['questionsSolved'] ?? 0,
    );
  }

  factory UserStats.empty() {
    return UserStats(
      quizzesTaken: 0, 
      totalScore: 0, 
      questionsSolved: 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizzesTaken': quizzesTaken,
      'totalScore': totalScore,
      'questionsSolved': questionsSolved,
    };
  }
  
  double get averageScore => quizzesTaken == 0 ? 0 : totalScore / quizzesTaken;
}
