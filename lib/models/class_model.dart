// 🎓 CLASS MODEL
// Represents a class/standard in the education system
class ClassModel {
  final String id;
  final int standard;

  ClassModel({
    required this.id,
    required this.standard,
  });

  // Create ClassModel from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ClassModel(
      id: docId ?? json['id'] ?? '',
      standard: json['standard'] ?? 0,
    );
  }

  // Convert ClassModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'standard': standard,
    };
  }

  // Create a copy with modified fields
  ClassModel copyWith({
    String? id,
    int? standard,
  }) {
    return ClassModel(
      id: id ?? this.id,
      standard: standard ?? this.standard,
    );
  }
}

// 📘 SUBJECT MODEL
// Represents a subject within a class (e.g., Science, Math)
class SubjectModel {
  final String id;
  final String subjectName;
  final List<ChapterModel> chapters; // For UI state management only

  SubjectModel({
    required this.id,
    required this.subjectName,
    this.chapters = const [],
  });

  // Create SubjectModel from JSON
  factory SubjectModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return SubjectModel(
      id: docId ?? json['id'] ?? '',
      subjectName: json['subject_name'] ?? '',
      chapters: const [], // Chapters loaded separately from subcollection
    );
  }

  // Convert SubjectModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'subject_name': subjectName,
    };
  }

  // Create a copy with modified fields
  SubjectModel copyWith({
    String? id,
    String? subjectName,
    List<ChapterModel>? chapters,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      chapters: chapters ?? this.chapters,
    );
  }
}

// 📄 CHAPTER MODEL (MERGED VERSION)
// Works for both UI (PDF display) and AI (RAG with summary)
class ChapterModel {
  final String id;
  final String chapterName;
  final String notesURL;
  final String? summary; // Optional: for AI/RAG summary

  ChapterModel({
    required this.id,
    required this.chapterName,
    required this.notesURL,
    this.summary,
  });

  // Create ChapterModel from JSON
  factory ChapterModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ChapterModel(
      id: docId ?? json['id'] ?? '',
      chapterName: json['chapter_name'] ?? '',
      notesURL: json['notesURL'] ?? '',
      summary: json['summary'],
    );
  }

  // Convert ChapterModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'chapter_name': chapterName,
      'notesURL': notesURL,
      if (summary != null) 'summary': summary,
    };
  }

  // Create a copy with modified fields
  ChapterModel copyWith({
    String? id,
    String? chapterName,
    String? notesURL,
    String? summary,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      chapterName: chapterName ?? this.chapterName,
      notesURL: notesURL ?? this.notesURL,
      summary: summary ?? this.summary,
    );
  }
}