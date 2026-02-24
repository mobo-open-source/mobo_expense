class UserModel {
  final int id;
  final String name;
  final String? jobTitle;
  final String? workEmail;
  final String? workPhone;
  final String? image1920;
  final List<dynamic>? userDetails;

  UserModel({
    required this.id,
    required this.name,
    this.jobTitle,
    this.userDetails,
    this.image1920,
    this.workEmail,
    this.workPhone,
  });

  ///  copyWith method
  UserModel copyWith({
    int? id,
    String? name,
    String? jobTitle,
    String? workEmail,
    String? workPhone,
    String? image1920,
    List<dynamic>? userDetails,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      workEmail: workEmail ?? this.workEmail,
      workPhone: workPhone ?? this.workPhone,
      image1920: image1920 ?? this.image1920,
      userDetails: userDetails ?? this.userDetails,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      jobTitle: json['job_title'] == false ? null : json['job_title'],
      image1920: json['image_1920'] == false ? null : json['image_1920'],
      workEmail: json['work_email'] == false ? null : json['work_email'],
      workPhone: json['work_phone'] == false ? null : json['work_phone'],
      userDetails: json['employee_id'] == false ? null : json['employee_id'],
    );
  }
}
