class StudentModel {
  final String id;
  final String name;
  final int classNumber;
  final String school;
  final String phone;

  StudentModel({
    required this.id,
    required this.name,
    required this.classNumber,
    required this.school,
    required this.phone,
  });

  // Convert StudentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'classNumber': classNumber,
      'school': school,
      'phone': phone,
    };
  }

  // Create StudentModel from JSON with robust type conversion
  factory StudentModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return StudentModel(
      id: docId ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      classNumber: json['classNumber'] is int 
          ? json['classNumber'] 
          : int.tryParse(json['classNumber']?.toString() ?? '0') ?? 0,
      school: json['school']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  // Create a copy with modified fields
  StudentModel copyWith({
    String? id,
    String? name,
    int? classNumber,
    String? school,
    String? phone,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      classNumber: classNumber ?? this.classNumber,
      school: school ?? this.school,
      phone: phone ?? this.phone,
    );
  }
}