import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;         // Firebase Auth UID
  final String? name;      // Optional, if you collect name
  final String classLevel; // e.g., "5", "7", "10", "KG"
  final Timestamp createdAt;

  UserProfile({
    required this.id,
    this.name,
    required this.classLevel,
    required this.createdAt,
  });

  // Convert Firestore JSON → UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json, String id) {
    return UserProfile(
      id: id,
      name: json['name'] as String?,
      classLevel: json['classLevel'] as String? ?? "",
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  // Convert UserProfile → Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'classLevel': classLevel,
      'createdAt': createdAt,
    };
  }
}
