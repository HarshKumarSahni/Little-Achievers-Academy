// This model is for tracking student's note reading progress
// Not needed for the main notes functionality - use class_model.dart instead

class NotesProgressModel {
  final String studentId;
  final String classDoc;
  final String subjectDoc;
  final String chapterDoc;
  final DateTime lastAccessed;
  final bool isCompleted;

  NotesProgressModel({
    required this.studentId,
    required this.classDoc,
    required this.subjectDoc,
    required this.chapterDoc,
    required this.lastAccessed,
    this.isCompleted = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'class_doc': classDoc,
      'subject_doc': subjectDoc,
      'chapter_doc': chapterDoc,
      'last_accessed': lastAccessed.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  // Create from JSON
  factory NotesProgressModel.fromJson(Map<String, dynamic> json) {
    return NotesProgressModel(
      studentId: json['student_id'] ?? '',
      classDoc: json['class_doc'] ?? '',
      subjectDoc: json['subject_doc'] ?? '',
      chapterDoc: json['chapter_doc'] ?? '',
      lastAccessed: json['last_accessed'] != null
          ? DateTime.parse(json['last_accessed'])
          : DateTime.now(),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  // Create a copy with modified fields
  NotesProgressModel copyWith({
    String? studentId,
    String? classDoc,
    String? subjectDoc,
    String? chapterDoc,
    DateTime? lastAccessed,
    bool? isCompleted,
  }) {
    return NotesProgressModel(
      studentId: studentId ?? this.studentId,
      classDoc: classDoc ?? this.classDoc,
      subjectDoc: subjectDoc ?? this.subjectDoc,
      chapterDoc: chapterDoc ?? this.chapterDoc,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// NOTE: For the main notes functionality, use the models in class_model.dart:
// - ClassModel (for class 8 document)
// - SubjectModel (for english, hindi, etc. documents)
// - ChapterModel (for chapter 1, chapter 2 documents)