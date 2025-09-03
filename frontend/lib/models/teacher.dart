class Teacher {
  final String id;
  final String name;
  final String email;
  final String department;
  final String? phone;
  final String? office;
  final String? profileImage;
  final List<String> subjects;
  final int experience;
  final List<String> qualifications;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    this.phone,
    this.office,
    this.profileImage,
    this.subjects = const [],
    this.experience = 0,
    this.qualifications = const [],
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      phone: json['phone'],
      office: json['office'],
      profileImage: json['profileImage'],
      subjects: List<String>.from(json['subjects'] ?? []),
      experience: json['experience'] ?? 0,
      qualifications: List<String>.from(json['qualifications'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'department': department,
      'phone': phone,
      'office': office,
      'profileImage': profileImage,
      'subjects': subjects,
      'experience': experience,
      'qualifications': qualifications,
    };
  }
}
